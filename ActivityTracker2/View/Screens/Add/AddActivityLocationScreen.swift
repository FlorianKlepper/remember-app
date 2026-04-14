// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen — GPS-Autofill oder Suche

import SwiftUI
import MapKit

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows. Bietet zwei Entscheidungspunkte:
/// 1. Aktuellen GPS-Standort verwenden (mit MiniMap-Vorschau)
/// 2. Ort manuell über MKLocalSearch suchen
///
/// Journal-Sonderfall: Wenn `isJournalCategory` und `hasHomeLocation`,
/// erscheint ein zusätzlicher "Zuhause"-Button oberhalb von Punkt 1.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(UserSettings.self)         private var userSettings
    @Environment(MapViewModel.self)         private var mapVM

    // MARK: Navigation

    /// Binding auf den NavigationPath von `AddActivityCategoryScreen`.
    @Binding var navigationPath: NavigationPath

    // MARK: State

    @State private var isLoadingLocation = false
    @State private var locationError: String? = nil
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Journal-Sonderfall: Zuhause-Button ───────────────
                if addActivityVM.isJournalCategory && userSettings.hasHomeLocation {
                    homeButton
                }

                // ── Entscheidungspunkt 1: Aktueller Standort ─────────
                currentLocationSection

                // ── Oder-Trennlinie ──────────────────────────────────
                orDivider

                // ── Entscheidungspunkt 2: Ort suchen ─────────────────
                searchSection
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .navigationTitle(String(localized: "add.step2.title", defaultValue: "Ort"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            handleAppear()
        }
        // .task(id:) startet neu wenn searchText sich ändert und cancelt vorherige Task
        .task(id: searchText) {
            await performSearch()
        }
    }

    // MARK: Journal — Zuhause-Button

    @ViewBuilder
    private var homeButton: some View {
        Button {
            addActivityVM.useHomeLocation(from: userSettings)
            navigationPath.append(3)
        } label: {
            Label(
                String(localized: "add.location.home", defaultValue: "Zuhause verwenden"),
                systemImage: "house.fill"
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(Color(hex: "#E8593C"))
    }

    // MARK: Entscheidungspunkt 1 — Aktueller Standort

    @ViewBuilder
    private var currentLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("add.location.current")
                .font(.caption)
                .foregroundStyle(.secondary)

            if isLoadingLocation {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("add.location.loading")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

            } else if let coordinate = addActivityVM.pendingCoordinate {
                MiniMapView(coordinate: coordinate)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(addActivityVM.pendingLocationName ?? "...")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

            } else if locationError != nil {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.slash")
                            .foregroundStyle(.secondary)
                        Text("add.location.error")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        Button(String(localized: "add.location.retry")) {
                            locationError = nil
                            Task { await fetchLocation() }
                        }
                        .buttonStyle(.bordered)

                        // ── Simulator-Fallback ─────────────────────────────
                        // GPS ist im Simulator nicht verfügbar — Demo-Koordinate
                        // (München) ermöglicht den kompletten Add-Flow zu testen.
                        Button("München (Demo)") {
                            addActivityVM.pendingCoordinate = CLLocationCoordinate2D(
                                latitude:  AppConstants.defaultLatitude,
                                longitude: AppConstants.defaultLongitude
                            )
                            addActivityVM.pendingLocationName = "München, Bayern, Deutschland"
                            locationError = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

            } else {
                // Platzhalter bevor der erste GPS-Wert eingetroffen ist
                Color(.systemGray6)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }

        Button {
            navigationPath.append(3)
        } label: {
            Text("add.location.use")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(hex: "#E8593C"))
        .disabled(addActivityVM.pendingCoordinate == nil)
    }

    // MARK: Oder-Trennlinie

    private var orDivider: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
            Text("general.or")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
        }
    }

    // MARK: Entscheidungspunkt 2 — Suche

    @ViewBuilder
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Suchfeld
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(
                    String(localized: "add.location.search", defaultValue: "Ort suchen..."),
                    text: $searchText
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))

            // Suchergebnisse (max. 5)
            if !searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchResults.indices, id: \.self) { index in
                        let mapItem = searchResults[index]

                        Button {
                            selectResult(mapItem)
                        } label: {
                            let placemark = mapItem.placemark
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mapItem.name ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)

                                if let locality = placemark.locality,
                                   locality != mapItem.name {
                                    Text(locality)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }

                        if index < searchResults.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: Private Logic

    private func handleAppear() {
        // Koordinate bereits gesetzt (z.B. nach Back-Navigation) → nichts tun
        guard addActivityVM.pendingCoordinate == nil else { return }
        Task { await fetchLocation() }
    }

    private func fetchLocation() async {
        isLoadingLocation = true
        defer { isLoadingLocation = false }

        do {
            let coordinate = try await locationManager.fetchCurrentLocation()
            addActivityVM.pendingCoordinate = coordinate

            // Reverse Geocoding — non-blocking, Ergebnis kommt asynchron auf Main Thread
            geocodeManager.geocode(coordinate) { result in
                let parts = [result.city, result.region, result.country].compactMap { $0 }
                addActivityVM.pendingLocationName = parts.isEmpty ? nil : parts.joined(separator: ", ")
            }
        } catch {
            locationError = error.localizedDescription
        }
    }

    /// Startet MKLocalSearch mit 300ms Debounce.
    /// Wird via `.task(id: searchText)` aufgerufen — vorherige Task wird automatisch gecancelt.
    private func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        // 300ms Debounce — CancellationError bei searchText-Änderung beendet Task sauber
        do {
            try await Task.sleep(for: .milliseconds(300))
        } catch {
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapVM.region

        let search = MKLocalSearch(request: request)
        if let response = try? await search.start() {
            searchResults = Array(response.mapItems.prefix(5))
        } else {
            searchResults = []
        }
    }

    /// Setzt pendingCoordinate + pendingLocationName aus dem Suchergebnis
    /// und navigiert sofort zu Screen 3. Reverse Geocoding läuft non-blocking nach.
    private func selectResult(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate  // MKPlacemark.coordinate, iOS 17+
        addActivityVM.pendingCoordinate = coordinate
        addActivityVM.pendingLocationName = mapItem.name

        // Reverse Geocoding verfeinert pendingLocationName non-blocking
        geocodeManager.geocode(coordinate) { result in
            let parts = [result.city, result.region, result.country].compactMap { $0 }
            if !parts.isEmpty {
                addActivityVM.pendingLocationName = parts.joined(separator: ", ")
            }
        }

        navigationPath.append(3)
    }
}

// MARK: - Preview

#Preview("Add — Step 2: Ort") {
    let analytics   = AnalyticsManager()
    let addVM       = AddActivityViewModel()
    let locationMgr = LocationManager()
    let geocodeMgr  = GeocodeManager()
    let settings    = UserSettings()
    let mapVM       = MapViewModel()

    // Koordinate vorbelegen für Map-Preview
    addVM.pendingCoordinate = CLLocationCoordinate2D(
        latitude:  AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude
    )
    addVM.pendingLocationName = "München, Bayern, Deutschland"

    return NavigationStack {
        AddActivityLocationScreen(navigationPath: .constant(NavigationPath()))
    }
    .environment(addVM)
    .environment(locationMgr)
    .environment(geocodeMgr)
    .environment(settings)
    .environment(mapVM)
}
