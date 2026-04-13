// AddActivityLocationScreen.swift
// ActivityTracker2 — Remember
// Step 2 des Add-Flows: Ort wählen (GPS-Autofill)

import SwiftUI
import CoreLocation

// MARK: - AddActivityLocationScreen

/// Screen 2 des Add-Flows. Holt die GPS-Position per `LocationManager.fetchCurrentLocation()`
/// und befüllt `addActivityVM.pendingCoordinate` + `pendingLocationName`.
///
/// Journal-Shortcut: Wenn `addActivityVM.isJournalCategory` und `userSettings.hasHomeLocation`,
/// wird die gespeicherte Heimat-Location direkt verwendet und sofort zu Screen 3 navigiert.
struct AddActivityLocationScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(LocationManager.self)      private var locationManager
    @Environment(GeocodeManager.self)       private var geocodeManager
    @Environment(UserSettings.self)         private var userSettings

    // MARK: Navigation

    /// Binding auf den NavigationPath von `AddActivityCategoryScreen`.
    @Binding var navigationPath: NavigationPath

    // MARK: State

    @State private var isLoadingLocation = false
    @State private var locationError: String? = nil

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoadingLocation {
                    loadingView
                } else if let coordinate = addActivityVM.pendingCoordinate {
                    locationPreview(coordinate: coordinate)
                } else if locationError != nil {
                    errorView
                }
            }
            .padding(.vertical, 24)
        }
        .navigationTitle(String(localized: "add.step2.title", defaultValue: "Ort"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            handleAppear()
        }
    }

    // MARK: Sub-Views

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("add.location.loading")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    @ViewBuilder
    private func locationPreview(coordinate: CLLocationCoordinate2D) -> some View {
        MiniMapView(coordinate: coordinate)
            .padding(.horizontal)

        if let name = addActivityVM.pendingLocationName {
            Label(name, systemImage: "mappin")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        Button {
            navigationPath.append(3)
        } label: {
            Text("button.continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color(hex: "#E8593C"),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("add.location.error")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(String(localized: "add.location.retry")) {
                locationError = nil
                Task { await fetchLocation() }
            }
            .buttonStyle(.bordered)

            // ── Simulator-Fallback ───────────────────────────────
            // GPS ist im Simulator nicht verfügbar — Demo-Koordinate (München)
            // ermöglicht den kompletten Add-Flow trotzdem zu testen.
            Button("München (Demo)") {
                addActivityVM.pendingCoordinate = CLLocationCoordinate2D(
                    latitude: AppConstants.defaultLatitude,
                    longitude: AppConstants.defaultLongitude
                )
                addActivityVM.pendingLocationName = "München, Bayern, Deutschland"
                locationError = nil
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#E8593C"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal)
    }

    // MARK: Private Logic

    private func handleAppear() {
        // Journal-Shortcut: Heimat-Koordinate direkt nutzen, sofort zu Screen 3
        if addActivityVM.isJournalCategory && userSettings.hasHomeLocation {
            addActivityVM.useHomeLocation(from: userSettings)
            navigationPath.append(3)
            return
        }

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

            // Reverse Geocoding — non-blocking, fehler werden still ignoriert
            if let result = try? await geocodeManager.reverseGeocode(coordinate) {
                let parts = [result.city, result.region, result.country].compactMap { $0 }
                addActivityVM.pendingLocationName = parts.isEmpty ? nil : parts.joined(separator: ", ")
            }
        } catch {
            locationError = error.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview("Add — Step 2: Ort") {
    let analytics  = AnalyticsManager()
    let addVM      = AddActivityViewModel()
    let locationMgr = LocationManager()
    let geocodeMgr  = GeocodeManager()
    let settings   = UserSettings()

    // Koordinate vorbelegen für Map-Preview
    addVM.pendingCoordinate = CLLocationCoordinate2D(
        latitude: AppConstants.defaultLatitude,
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
