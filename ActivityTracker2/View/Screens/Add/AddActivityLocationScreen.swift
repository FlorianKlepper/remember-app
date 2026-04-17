// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen — Mini Map + Echtzeit-Suche

import SwiftUI
import MapKit
import CoreLocation

// MARK: - NearbyPlace

/// Nahegelegener POI aus MKLocalSearch.
private struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let distance: Double               // Meter
    let coordinate: CLLocationCoordinate2D
}

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows mit zwei Modi:
///
/// **Normal** (nicht fokussiert): Mini Map + Aktueller-Standort-Button + Nearby Places.
/// **Suche** (fokussiert): Suchfeld + Abbrechen + kompakte Standort-Zeile + Vorschläge.
///
/// Kein eigener NavigationStack — läuft innerhalb des NavigationStack von AddActivityCategoryScreen.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(UserSettings.self)         private var userSettings

    // MARK: Navigation

    @Binding var navigationPath: NavigationPath
    @State private var navigateToText = false

    // MARK: State

    @State private var searchManager     = LocationSearchManager()
    @State private var locationName      = ""
    @State private var isLoadingLocation = false
    @State private var locationError: String? = nil
    @State private var nearbyPlaces: [NearbyPlace] = []
    @FocusState private var searchFocused: Bool

    // MARK: Private

    /// Farbe der gewählten Kategorie — für Button + Icons.
    private var categoryColor: Color {
        let allCats = Category.mvpCategories + Category.plusCategories
        guard let id  = addActivityVM.selectedCategoryId,
              let cat = allCats.first(where: { $0.id == id })
        else { return Color(hex: "#E8593C") }
        return Color(hex: cat.colorHex)
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {

            searchBar

            Divider()

            if searchFocused {
                searchModeContent
            } else {
                normalModeContent
            }
        }
        .animation(.easeInOut(duration: 0.2), value: searchFocused)
        .navigationTitle(String(localized: "add.step2.title", defaultValue: "Ort"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToText) {
            AddActivityTextScreen()
        }
        .onAppear {
            guard addActivityVM.pendingCoordinate == nil else {
                fetchLocationName()
                return
            }
            Task { await fetchLocation() }
            loadNearbyPlaces()
        }
    }

    // MARK: Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    String(localized: "add.location.search", defaultValue: "Ort suchen..."),
                    text: Binding(
                        get: { searchManager.searchText },
                        set: { newValue in
                            searchManager.searchText = newValue
                            searchManager.search(newValue)
                        }
                    )
                )
                .focused($searchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.default)
                .onSubmit { searchFocused = false }

                if !searchManager.searchText.isEmpty {
                    Button {
                        searchManager.searchText = ""
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

            if searchFocused {
                Button(String(localized: "general.cancel", defaultValue: "Abbrechen")) {
                    searchManager.searchText = ""
                    searchFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: searchFocused)
    }

    // MARK: Normal Mode

    private var normalModeContent: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Journal: Zuhause-Schnellzugriff
                if addActivityVM.isJournalCategory && userSettings.hasHomeLocation {
                    homeButton
                }

                // Mini Map + Standort-Button
                currentLocationCard

                // Nearby Places
                if !nearbyPlaces.isEmpty {
                    nearbySection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: Current Location Card

    @ViewBuilder
    private var currentLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header-Zeile
            HStack(spacing: 12) {
                locationIcon(systemName: "location.fill", color: categoryColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey("add.location.current"))
                        .font(.body)
                    Text(locationName.isEmpty
                         ? String(localized: "add.location.loading", defaultValue: "Wird ermittelt...")
                         : locationName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Mini Map / Ladeindikator / Fehler
            if isLoadingLocation {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(LocalizedStringKey("add.location.loading"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

            } else if let coordinate = addActivityVM.pendingCoordinate {
                MiniMapView(coordinate: coordinate)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

            } else if locationError != nil {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.slash")
                            .foregroundStyle(.secondary)
                        Text(LocalizedStringKey("add.location.error"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        Button(String(localized: "add.location.retry", defaultValue: "Erneut versuchen")) {
                            locationError = nil
                            Task { await fetchLocation() }
                        }
                        .buttonStyle(.bordered)

                        Button("München (Demo)") {
                            addActivityVM.pendingCoordinate   = CLLocationCoordinate2D(
                                latitude:  AppConstants.defaultLatitude,
                                longitude: AppConstants.defaultLongitude
                            )
                            addActivityVM.pendingLocationName = "München, Bayern, Deutschland"
                            locationName  = "München, Deutschland"
                            locationError = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

            } else {
                Color(.systemGray6)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // ── Kleiner Capsule-Button in Kategorie-Farbe ──────────
            Button {
                navigateToTextScreen()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                    Text(String(localized: "add.location.use",
                                defaultValue: "Aktuellen Standort verwenden"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(categoryColor))
            }
            .buttonStyle(.plain)
            .disabled(addActivityVM.pendingCoordinate == nil)
            .opacity(addActivityVM.pendingCoordinate == nil ? 0.4 : 1.0)
        }
    }

    // MARK: Nearby Section

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text(String(localized: "add.location.nearby", defaultValue: "In der Nähe"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(nearbyPlaces) { place in
                    Button {
                        addActivityVM.pendingCoordinate   = place.coordinate
                        addActivityVM.pendingLocationName = place.name
                        geocodeManager.geocode(place.coordinate) { result in
                            let parts = [result.city, result.region, result.country].compactMap { $0 }
                            if !parts.isEmpty {
                                addActivityVM.pendingLocationName = parts.joined(separator: ", ")
                            }
                        }
                        navigateToTextScreen()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "mappin")
                                    .font(.system(size: 14))
                                    .foregroundStyle(categoryColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(formatDistance(place.distance))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)

                    if place.id != nearbyPlaces.last?.id {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
            )
        }
    }

    // MARK: Search Mode

    private var searchModeContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {

                // Journal: Zuhause-Schnellzugriff (kompakt)
                if addActivityVM.isJournalCategory && userSettings.hasHomeLocation {
                    Button {
                        addActivityVM.useHomeLocation(from: userSettings)
                        navigateToTextScreen()
                    } label: {
                        compactRow(
                            icon: "house.fill",
                            iconColor: categoryColor,
                            title: String(localized: "add.location.home",
                                         defaultValue: "Zuhause verwenden"),
                            subtitle: userSettings.homeLocationName.isBlank
                                ? nil : userSettings.homeLocationName
                        )
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 64)
                }

                // Aktueller Standort (kompakt)
                Button {
                    useCurrentLocation()
                } label: {
                    compactRow(
                        icon: "location.fill",
                        iconColor: categoryColor,
                        title: String(localized: "add.location.current",
                                     defaultValue: "Aktueller Standort"),
                        subtitle: locationName.isEmpty ? nil : locationName
                    )
                }
                .buttonStyle(.plain)
                .disabled(locationManager.currentLocation == nil)

                Divider().padding(.leading, 64)

                // Vorschläge
                if !searchManager.searchText.isEmpty {
                    if searchManager.suggestions.isEmpty && !searchManager.isSearching {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                            Text(LocalizedStringKey("add.location.no.results"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                    } else {
                        ForEach(searchManager.suggestions, id: \.self) { suggestion in
                            Button {
                                guard !suggestion.title.isEmpty else { return }
                                selectSuggestion(suggestion)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemGray5))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: iconFor(suggestion))
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 15))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        highlightedText(
                                            suggestion.title,
                                            ranges: suggestion.titleHighlightRanges
                                        )
                                        .font(.body)
                                        .foregroundStyle(.primary)

                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 64)
                        }
                    }
                }
            }
        }
    }

    // MARK: Shared Sub-Views

    private var homeButton: some View {
        Button {
            addActivityVM.useHomeLocation(from: userSettings)
            navigateToTextScreen()
        } label: {
            Label(
                String(localized: "add.location.home", defaultValue: "Zuhause verwenden"),
                systemImage: "house.fill"
            )
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(categoryColor)
    }

    private func compactRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?
    ) -> some View {
        HStack(spacing: 12) {
            locationIcon(systemName: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func locationIcon(systemName: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .foregroundStyle(color)
                .font(.system(size: 16))
        }
    }

    // MARK: Private Logic

    private func fetchLocation() async {
        isLoadingLocation = true
        defer { isLoadingLocation = false }

        do {
            let coordinate = try await locationManager.fetchCurrentLocation()
            addActivityVM.pendingCoordinate = coordinate
            geocodeManager.geocode(coordinate) { result in
                let parts = [result.city, result.region, result.country].compactMap { $0 }
                addActivityVM.pendingLocationName = parts.isEmpty ? nil : parts.joined(separator: ", ")
                locationName = [result.city, result.country].compactMap { $0 }.joined(separator: ", ")
            }
        } catch {
            locationError = error.localizedDescription
        }
    }

    private func fetchLocationName() {
        guard let coord = addActivityVM.pendingCoordinate else { return }
        geocodeManager.geocode(coord) { result in
            locationName = [result.city, result.country].compactMap { $0 }.joined(separator: ", ")
        }
    }

    private func useCurrentLocation() {
        guard let coord = locationManager.currentLocation else { return }
        addActivityVM.pendingCoordinate   = coord
        addActivityVM.pendingLocationName = locationName.isEmpty ? nil : locationName
        geocodeManager.geocode(coord) { result in
            let parts = [result.city, result.region, result.country].compactMap { $0 }
            if !parts.isEmpty { addActivityVM.pendingLocationName = parts.joined(separator: ", ") }
        }
        navigateToTextScreen()
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        searchManager.selectSuggestion(suggestion) { coord, name, city, country in
            guard let coord else { return }
            DispatchQueue.main.async {
                addActivityVM.pendingCoordinate = coord
                let parts = [name, city, country].compactMap { $0?.isEmpty == false ? $0 : nil }
                addActivityVM.pendingLocationName = parts.isEmpty ? suggestion.title : parts.joined(separator: ", ")
                navigateToTextScreen()
            }
        }
    }

    private func navigateToTextScreen() {
        navigateToText = true
    }

    /// Lädt bis zu 5 nahegelegene POIs via MKLocalSearch.
    private func loadNearbyPlaces() {
        guard let coord = locationManager.currentLocation else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "points of interest"
        request.region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let userLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        search.start { response, _ in
            guard let items = response?.mapItems else { return }
            let places = items
                .prefix(5)
                .compactMap { item -> NearbyPlace? in
                    guard let name = item.name else { return nil }
                    let itemCoord = item.placemark.coordinate
                    let dist = userLocation.distance(
                        from: CLLocation(latitude: itemCoord.latitude, longitude: itemCoord.longitude)
                    )
                    return NearbyPlace(name: name, distance: dist, coordinate: itemCoord)
                }
                .sorted { $0.distance < $1.distance }

            DispatchQueue.main.async {
                nearbyPlaces = places
            }
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        meters < 1000
            ? "\(Int(meters)) m"
            : String(format: "%.1f km", meters / 1000)
    }

    // MARK: Private Helpers

    private func iconFor(_ suggestion: MKLocalSearchCompletion) -> String {
        let title    = suggestion.title.lowercased()
        let subtitle = suggestion.subtitle.lowercased()
        if subtitle.contains("restaurant") || title.contains("restaurant") { return "fork.knife" }
        if subtitle.contains("hotel")      || title.contains("hotel")      { return "bed.double.fill" }
        if subtitle.contains("airport")    || title.contains("flughafen")  { return "airplane" }
        if subtitle.contains("bahnhof")    || subtitle.contains("station") { return "tram.fill" }
        return "mappin.circle.fill"
    }

    private func highlightedText(_ text: String, ranges: [NSValue]) -> Text {
        var result  = Text("")
        var lastEnd = text.startIndex
        for value in ranges {
            let range = value.rangeValue
            guard let swiftRange = Range(range, in: text) else { continue }
            result  = result + Text(String(text[lastEnd..<swiftRange.lowerBound]))
            result  = result + Text(String(text[swiftRange])).bold()
            lastEnd = swiftRange.upperBound
        }
        return result + Text(String(text[lastEnd...]))
    }
}

// MARK: - Preview

#Preview("Add — Step 2: Ort") {
    let addVM       = AddActivityViewModel()
    let locationMgr = LocationManager()
    let geocodeMgr  = GeocodeManager()
    let settings    = UserSettings()

    addVM.selectedCategoryId  = "hiking"
    addVM.pendingCoordinate   = CLLocationCoordinate2D(
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
}
