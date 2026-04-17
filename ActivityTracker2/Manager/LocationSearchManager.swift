// LocationSearchManager.swift
// ActivityTracker2 — Remember
// MKLocalSearchCompleter-Wrapper mit Debounce für Echtzeit-Ortssuchvorschläge

@preconcurrency import MapKit
import Foundation
import CoreLocation

// MARK: - LocationSearchManager

/// Verwaltet `MKLocalSearchCompleter` für Echtzeit-Suchvorschläge.
/// Debounce: wartet 0.4 s nach dem letzten Tastendruck, bevor die Suche startet.
/// Max. 6 Ergebnisse — alle UI-Updates auf dem Main Thread via @MainActor.
@Observable
@MainActor
final class LocationSearchManager: NSObject, MKLocalSearchCompleterDelegate {

    // MARK: Properties

    var searchText: String = ""
    var suggestions: [MKLocalSearchCompletion] = []
    var isSearching: Bool = false

    // MARK: Private

    private let completer = MKLocalSearchCompleter()
    private var searchWorkItem: DispatchWorkItem?

    // MARK: Init

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    // MARK: Search

    /// Startet eine neue Suche mit 400 ms Debounce.
    /// Vorherige WorkItems werden gecancelt — kein unnötiger MapKit-Overhead.
    func search(_ text: String) {
        searchWorkItem?.cancel()

        guard !text.isEmpty else {
            suggestions = []
            isSearching = false
            return
        }

        isSearching = true

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.completer.queryFragment = text
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }

    // MARK: MKLocalSearchCompleterDelegate

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.prefix(6).map { $0 }
        DispatchQueue.main.async { [weak self] in
            self?.suggestions = Array(results)
            self?.isSearching = false
        }
    }

    nonisolated func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.suggestions = []
            self?.isSearching = false
        }
    }

    // MARK: Public Methods

    /// Löst einen Vorschlag in Koordinate + Ortsinformationen auf via `MKLocalSearch`.
    func selectSuggestion(
        _ suggestion: MKLocalSearchCompletion,
        completion: @escaping (
            CLLocationCoordinate2D?,
            String?, String?, String?
        ) -> Void
    ) {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search  = MKLocalSearch(request: request)

        search.start { response, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let item = response?.mapItems.first
                else {
                    completion(nil, nil, nil, nil)
                    return
                }
                completion(
                    item.placemark.coordinate,
                    item.name ?? suggestion.title,
                    item.placemark.locality,
                    item.placemark.country
                )
            }
        }
    }
}
