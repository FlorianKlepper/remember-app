// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen — Mini Map + Echtzeit-Suche

import SwiftUI
import MapKit

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows mit zwei Modi:
///
/// **Normal** (nicht fokussiert): Suchfeld + "Aktueller Standort"-Karte mit Mini Map.
/// **Suche** (fokussiert): Suchfeld + Abbrechen-Button + kompakte Standort-Zeile + Vorschläge.
///
/// Journal-Sonderfall: Bei Journal-Kategorie + gespeicherter Heimat-Location
/// erscheint ein zusätzlicher "Zuhause"-Button.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(UserSettings.self)         private var userSettings

    // MARK: Navigation

    @Binding var navigationPath: NavigationPath

    // MARK: State

    @State private var searchManager     = LocationSearchManager()
    @State private var locationName      = ""
    @State private var isLoadingLocation = false
    @State private var locationError: String? = nil
    @FocusState private var searchFocused: Bool

    // MARK: Body

    var body: some View {
        NavigationStack {
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
            .onAppear {
                guard addActivityVM.pendingCoordinate == nil else {
                    fetchLocationName()
                    return
                }
                Task { await fetchLocation() }
            }
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
                        set: { searchManager.searchText = $0 }
                    )
                )
                .focused($searchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
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

    // MARK: Normal Mode — Mini Map sichtbar

    private var normalModeContent: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Journal: Zuhause-Schnellzugriff
                if addActivityVM.isJournalCategory && userSettings.hasHomeLocation {
                    homeButton
                }

                // Aktueller Standort-Karte
                currentLocationCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var currentLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header-Zeile
            HStack(spacing: 12) {
                locationIcon(systemName: "location.fill", color: Color(hex: "#E8593C"))
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

                        // Simulator-Fallback: GPS nicht verfügbar im Simulator
                        Button("München (Demo)") {
                            addActivityVM.pendingCoordinate = CLLocationCoordinate2D(
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

            // Verwenden-Button
            Button {
                navigateToTextScreen()
            } label: {
                Text(LocalizedStringKey("add.location.use"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#E8593C"))
            .disabled(addActivityVM.pendingCoordinate == nil)
        }
    }

    // MARK: Search Mode — Vorschläge sichtbar

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
                            iconColor: Color(hex: "#E8593C"),
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
                        iconColor: Color(hex: "#E8593C"),
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
        .tint(Color(hex: "#E8593C"))
    }

    /// Kompakte Zeile für den Suchmodus (Aktueller Standort, Zuhause).
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

    /// Farbiger Kreis-Icon für Standort-Zeilen.
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

    /// GPS-Koordinate async holen und Mini Map befüllen.
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

    /// Nur Ortsname aus bereits gesetzter Koordinate laden (bei Back-Navigation).
    private func fetchLocationName() {
        guard let coord = addActivityVM.pendingCoordinate else { return }
        geocodeManager.geocode(coord) { result in
            locationName = [result.city, result.country].compactMap { $0 }.joined(separator: ", ")
        }
    }

    /// GPS-Standort als Aktivitäts-Ort übernehmen und zu Step 3 navigieren.
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

    /// Suchvorschlag auflösen, ViewModel befüllen, zu Step 3 navigieren.
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        searchManager.selectSuggestion(suggestion) { coord, name, city, country in
            guard let coord else { return }
            addActivityVM.pendingCoordinate = coord
            let parts = [name, city, country].compactMap { $0?.isEmpty == false ? $0 : nil }
            addActivityVM.pendingLocationName = parts.isEmpty ? suggestion.title : parts.joined(separator: ", ")
            navigateToTextScreen()
        }
    }

    private func navigateToTextScreen() {
        navigationPath.append(3)
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
