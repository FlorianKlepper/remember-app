// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen

import SwiftUI
import MapKit
import CoreLocation

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows: Ortsuche via MKLocalSearchCompleter.
/// Läuft innerhalb des NavigationStack von AddActivityCategoryScreen.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(\.dismiss)                 private var dismiss

    // MARK: State

    @State private var searchText      = ""
    @State private var suggestions:      [MKLocalSearchCompletion] = []
    @State private var locationName    = ""
    @State private var navigateToText  = false
    @State private var completer       = SearchCompleter()

    // MARK: Private

    private var categoryColor: Color {
        let all = Category.mvpCategories + Category.plusCategories
        guard let id  = addActivityVM.selectedCategoryId,
              let cat = all.first(where: { $0.id == id })
        else { return Color(hex: "#E8593C") }
        return Color(hex: cat.colorHex)
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {

            // ── Suchfeld ─────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    String(localized: "add.location.search", defaultValue: "Ort suchen..."),
                    text: $searchText
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.default)
                .onChange(of: searchText) { _, new in
                    completer.search(new) { results in
                        suggestions = results
                    }
                }

                if !searchText.isEmpty {
                    Button {
                        searchText   = ""
                        suggestions  = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(16)

            Divider()

            // ── Liste ─────────────────────────────────────────────
            List {

                // Aktueller Standort
                Button {
                    useCurrentLocation()
                } label: {
                    locationRow(
                        icon: "location.fill",
                        iconColor: categoryColor,
                        title: String(localized: "add.location.current",
                                      defaultValue: "Aktueller Standort"),
                        subtitle: locationName.isEmpty
                            ? String(localized: "add.location.loading",
                                     defaultValue: "Wird ermittelt...")
                            : locationName
                    )
                }
                .listRowBackground(Color.clear)
                .disabled(locationManager.currentLocation == nil)

                // Suchergebnisse
                ForEach(suggestions.prefix(6), id: \.self) { suggestion in
                    Button {
                        selectSuggestion(suggestion)
                    } label: {
                        locationRow(
                            icon: "mappin.circle.fill",
                            iconColor: Color(.systemGray3),
                            title: suggestion.title,
                            subtitle: suggestion.subtitle.isEmpty ? nil : suggestion.subtitle
                        )
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle(String(localized: "add.step2.title", defaultValue: "Ort"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                        dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToText) {
            AddActivityTextScreen()
        }
        .onAppear {
            fetchCurrentLocation()
        }
    }

    // MARK: Row Helper

    private func locationRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 15))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: Private Logic

    private func fetchCurrentLocation() {
        guard let coord = locationManager.currentLocation else { return }
        geocodeManager.geocode(coord) { result in
            locationName = [result.city, result.country]
                .compactMap { $0 }
                .joined(separator: ", ")
        }
    }

    private func useCurrentLocation() {
        guard let coord = locationManager.currentLocation else { return }
        addActivityVM.pendingCoordinate   = coord
        addActivityVM.pendingLocationName = locationName.isEmpty ? nil : locationName
        navigateToText = true
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        MKLocalSearch(request: request).start { response, error in
            guard error == nil, let item = response?.mapItems.first else { return }
            DispatchQueue.main.async {
                addActivityVM.pendingCoordinate   = item.placemark.coordinate
                addActivityVM.pendingLocationName = [
                    item.name ?? suggestion.title,
                    item.placemark.locality,
                    item.placemark.country
                ]
                .compactMap { $0?.isEmpty == false ? $0 : nil }
                .joined(separator: ", ")
                navigateToText = true
            }
        }
    }
}

// MARK: - SearchCompleter

/// Einfacher MKLocalSearchCompleter-Wrapper ohne @Observable.
/// Callback-basiert — thread-sicher via DispatchQueue.main.
private class SearchCompleter: NSObject, MKLocalSearchCompleterDelegate {

    private let completer  = MKLocalSearchCompleter()
    private var onResults: (([MKLocalSearchCompletion]) -> Void)?

    override init() {
        super.init()
        completer.delegate     = self
        completer.resultTypes  = [.address, .pointOfInterest]
    }

    /// Startet eine neue Suche. Leerer Text → leeres Ergebnis sofort.
    func search(_ text: String, completion: @escaping ([MKLocalSearchCompletion]) -> Void) {
        onResults = completion
        if text.isEmpty {
            completion([])
        } else {
            completer.queryFragment = text
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.onResults?(completer.results)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.onResults?([])
        }
    }
}

// MARK: - Preview

#Preview("Add — Step 2: Ort") {
    let addVM       = AddActivityViewModel()
    let locationMgr = LocationManager()
    let geocodeMgr  = GeocodeManager()

    addVM.selectedCategoryId = "hiking"

    return NavigationStack {
        AddActivityLocationScreen()
    }
    .environment(addVM)
    .environment(locationMgr)
    .environment(geocodeMgr)
}
