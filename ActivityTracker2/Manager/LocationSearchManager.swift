// LocationSearchManager.swift
// ActivityTracker2 — Remember
// MKLocalSearchCompleter-Wrapper für Echtzeit-Ortssuchvorschläge

import MapKit
import Foundation

// MARK: - LocationSearchManager

/// Verwaltet `MKLocalSearchCompleter` für Echtzeit-Suchvorschläge.
/// Setze `searchText` — Vorschläge erscheinen automatisch in `suggestions`.
/// `selectSuggestion(_:completion:)` löst einen Vorschlag in eine Koordinate auf.
@Observable
class LocationSearchManager: NSObject, MKLocalSearchCompleterDelegate {

    // MARK: Properties

    /// Eingabetext — jede Änderung triggert eine neue Completer-Suche.
    var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                suggestions = []
            } else {
                completer.queryFragment = searchText
            }
        }
    }

    /// Aktuelle Vorschläge vom `MKLocalSearchCompleter`.
    var suggestions: [MKLocalSearchCompletion] = []

    /// `true` während eine Suche läuft.
    var isSearching: Bool = false

    // MARK: Private

    private let completer = MKLocalSearchCompleter()

    // MARK: Init

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [
            .address,
            .pointOfInterest,
            .query
        ]
    }

    // MARK: MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        suggestions = []
    }

    // MARK: Public Methods

    /// Löst einen Vorschlag in Koordinate + Ortsinformationen auf via `MKLocalSearch`.
    /// - Parameters:
    ///   - suggestion: Ausgewählter `MKLocalSearchCompletion`.
    ///   - completion: Callback mit `(coordinate, name, city, country)` — alle optional.
    func selectSuggestion(
        _ suggestion: MKLocalSearchCompletion,
        completion: @escaping (
            CLLocationCoordinate2D?,
            String?, String?, String?
        ) -> Void
    ) {
        let request = MKLocalSearch.Request(completion: suggestion)
        let search  = MKLocalSearch(request: request)

        search.start { response, _ in
            guard let item = response?.mapItems.first else {
                completion(nil, nil, nil, nil)
                return
            }
            completion(
                item.placemark.coordinate,
                item.name,
                item.placemark.locality,
                item.placemark.country
            )
        }
    }
}
