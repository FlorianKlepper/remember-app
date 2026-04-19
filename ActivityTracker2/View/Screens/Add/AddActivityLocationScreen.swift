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
    @State private var nearbyPlaces:   [NearbyPlace] = []

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

                // In der Nähe (nur wenn keine Suche aktiv)
                if searchText.isEmpty && !nearbyPlaces.isEmpty {
                    Section(String(localized: "add.location.nearby",
                                   defaultValue: "In der Nähe")) {
                        ForEach(nearbyPlaces) { place in
                            Button {
                                selectNearbyPlace(place)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(categoryColor.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundStyle(categoryColor)
                                            .font(.system(size: 15))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(place.name)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        Text(place.subtitle.isEmpty
                                            ? formatDistance(place.distance)
                                            : "\(place.subtitle) · \(formatDistance(place.distance))"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
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
            loadNearbyPlaces()
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
                addActivityVM.pendingCity         = item.placemark.locality
                addActivityVM.pendingCountry      = item.placemark.country
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

    private func loadNearbyPlaces() {
        guard let coord = locationManager.currentLocation else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant cafe bar shop"
        request.region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        )
        request.resultTypes = .pointOfInterest

        let userLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        MKLocalSearch(request: request).start { response, _ in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                nearbyPlaces = items
                    .compactMap { item -> NearbyPlace? in
                        guard let name = item.name else { return nil }
                        let itemLocation = CLLocation(
                            latitude: item.placemark.coordinate.latitude,
                            longitude: item.placemark.coordinate.longitude
                        )
                        let distance = userLocation.distance(from: itemLocation)
                        guard distance <= 500 else { return nil }
                        return NearbyPlace(
                            name: name,
                            subtitle: item.placemark.thoroughfare ?? "",
                            distance: distance,
                            coordinate: item.placemark.coordinate,
                            city: item.placemark.locality,
                            country: item.placemark.country
                        )
                    }
                    .sorted { $0.distance < $1.distance }
                    .prefix(5)
                    .map { $0 }
            }
        }
    }

    private func selectNearbyPlace(_ place: NearbyPlace) {
        addActivityVM.pendingCoordinate   = place.coordinate
        addActivityVM.pendingLocationName = place.name
        addActivityVM.pendingCity         = place.city
        addActivityVM.pendingCountry      = place.country
        navigateToText = true
    }

    private func formatDistance(_ meters: Double) -> String {
        meters < 1000
            ? "\(Int(meters))m entfernt"
            : String(format: "%.1fkm entfernt", meters / 1000)
    }
}

// MARK: - NearbyPlace

/// Ergebnis aus MKLocalSearch — ein Point of Interest in der Nähe des aktuellen Standorts.
private struct NearbyPlace: Identifiable {
    let id       = UUID()
    let name:       String
    let subtitle:   String
    let distance:   Double
    let coordinate: CLLocationCoordinate2D
    let city:       String?
    let country:    String?
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
