// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen

import SwiftUI
import MapKit
import CoreLocation
import UIKit

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows: Ortsuche via MKLocalSearchCompleter.
/// Läuft innerhalb des NavigationStack von AddActivityCategoryScreen.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(UserSettings.self)         private var userSettings
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

            // ── GPS verweigert — Link zu iOS Einstellungen ────────
            if locationManager.authorizationStatus == .denied ||
               locationManager.authorizationStatus == .restricted {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "location.slash")
                            .foregroundStyle(.orange)
                        Text(L10n.enableLocation)
                            .foregroundStyle(.orange)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .font(.caption)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            // ── Liste ─────────────────────────────────────────────
            List {

                // Zuhause (wenn gespeichert)
                if userSettings.hasHomeLocation {
                    Button {
                        addActivityVM.pendingCoordinate   = userSettings.homeCoordinate
                        addActivityVM.pendingLocationName = userSettings.homeName
                        addActivityVM.pendingCity         = userSettings.homeName
                        navigateToText = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#E8593C").opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "house.fill")
                                    .foregroundStyle(Color(hex: "#E8593C"))
                                    .font(.system(size: 15))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: "add.location.home",
                                            defaultValue: "Zuhause"))
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text(userSettings.homeName ?? "")
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
                ForEach(suggestions.prefix(10), id: \.self) { suggestion in
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
        // GPS-Berechtigung erteilt → Standort und Nearby Places neu laden
        .onReceive(NotificationCenter.default.publisher(for: .locationPermissionGranted)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchCurrentLocation()
                loadNearbyPlaces()
            }
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
        // Reverse Geocode um POI-Name zu ermitteln
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        ) { placemarks, _ in
            guard let place = placemarks?.first else { return }
            DispatchQueue.main.async {
                addActivityVM.pendingCoordinate   = coord
                addActivityVM.pendingLocationName = place.name ?? place.locality
                addActivityVM.pendingCity         = place.locality
                addActivityVM.pendingCountry      = place.country
                navigateToText = true
            }
        }
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        MKLocalSearch(request: request).start { response, error in
            guard error == nil, let item = response?.mapItems.first else { return }
            DispatchQueue.main.async {
                addActivityVM.pendingCoordinate   = item.placemark.coordinate
                addActivityVM.pendingLocationName = item.name ?? suggestion.title
                addActivityVM.pendingCity         = item.placemark.locality
                addActivityVM.pendingCountry      = item.placemark.country
                navigateToText = true
            }
        }
    }

    private func loadNearbyPlaces() {
        guard let coord = locationManager.currentLocation else { return }

        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        let queries = [
            "restaurant imbiss food",
            "cafe coffee bar",
            "shop store supermarket",
            "hotel",
            "bakery",
            "fast food",
            "pizza kebab",
            "pharmacy apotheke"
        ]

        var allPlaces: [NearbyPlace] = []
        let group = DispatchGroup()

        for query in queries {
            group.enter()

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            request.resultTypes = [.pointOfInterest, .address]

            MKLocalSearch(request: request).start { response, _ in
                defer { group.leave() }
                guard let items = response?.mapItems else { return }

                let places = items.compactMap { item -> NearbyPlace? in
                    guard let name = item.name, !name.isEmpty else { return nil }
                    let dist = userLoc.distance(from: CLLocation(
                        latitude:  item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    ))
                    guard dist <= 500 else { return nil }
                    return NearbyPlace(
                        name:       name,
                        subtitle:   item.placemark.thoroughfare ?? "",
                        distance:   dist,
                        coordinate: item.placemark.coordinate,
                        city:       item.placemark.locality,
                        country:    item.placemark.country
                    )
                }
                allPlaces.append(contentsOf: places)
            }
        }

        group.notify(queue: .main) {
            var seen = Set<String>()
            nearbyPlaces = allPlaces
                .filter { place in
                    guard !seen.contains(place.name) else { return false }
                    seen.insert(place.name)
                    return true
                }
                .sorted { $0.distance < $1.distance }
                .prefix(8)
                .map { $0 }
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
class SearchCompleter: NSObject, MKLocalSearchCompleterDelegate {

    private let completer  = MKLocalSearchCompleter()
    private var onResults: (([MKLocalSearchCompletion]) -> Void)?

    override init() {
        super.init()
        completer.delegate    = self
        // Alle Typen inkl. query (Berge, Regionen) — kein regionFilter → weltweit
        completer.resultTypes = [.address, .pointOfInterest, .query]
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
