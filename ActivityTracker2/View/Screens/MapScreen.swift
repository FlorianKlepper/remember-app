// MapScreen.swift
// ActivityTracker2 — Remember
// Homescreen der App — interaktive Karte mit permanentem Bottom Sheet

import SwiftUI
import MapKit

// MARK: - MapScreen

/// Startscreen der App. Zeigt alle Activities als Pins auf der Karte.
/// Layout:
///   Oben:         Blur-Material (Safe Area) + ChipBar + Controls
///   Darunter:     FilterStatusBanner wenn aktiv
///   Unten:        PermanentBottomSheet (immer sichtbar)
struct MapScreen: View {

    // MARK: Input

    /// Wenn `true` (Tab 1 — Liste): Sheet beim Erscheinen auf .large hochfahren.
    var isListMode: Bool = false

    // MARK: Environment

    @Environment(MapViewModel.self)      private var mapVM
    @Environment(FilterViewModel.self)   private var filterVM
    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(LocationManager.self)   private var locationManager

    // MARK: State

    @State private var cameraPosition: MapCameraPosition = .automatic

    // MARK: Private

    private var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    /// Höhe der oberen Safe Area (Notch / Dynamic Island).
    private var topSafeArea: CGFloat {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 47
    }

    private var uniqueLocations: [Location] {
        let filtered = activityVM.filteredActivities(categoryId: filterVM.selectedCategoryId)
        var seen = Set<UUID>()
        return filtered
            .compactMap { $0.location }
            .filter { seen.insert($0.id).inserted }
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Karte — volle Höhe ────────────────────────────────
            mapLayer
                .ignoresSafeArea()

            // ── Oben: Blur-Material + ChipBar + Controls ──────────
            VStack(spacing: 0) {

                // Milchiger Safe-Area-Bereich (Notch / Dynamic Island)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: topSafeArea)
                    .ignoresSafeArea(edges: .top)

                // ChipBar + Zoom/GPS in einer Zeile
                HStack(spacing: 0) {
                    CategoryChipBar(
                        filterVM: filterVM,
                        activities: activityVM.activities,
                        language: language
                    )

                    mapControlButtons
                        .padding(.trailing, 12)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(.ultraThinMaterial)

                // FilterStatusBanner — unter ChipBar, linksbündig
                if filterVM.isFilterActive {
                    HStack {
                        FilterStatusBanner(filterVM: filterVM, language: language)
                            .padding(.leading, 12)
                            .padding(.top, 6)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
            .animation(.easeInOut(duration: AppConstants.animationStandard),
                       value: filterVM.isFilterActive)

            // ── Permanenter Bottom Sheet ───────────────────────────
            PermanentBottomSheet(mapVM: mapVM)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // Tab-Modus → Sheet-Position beim Start setzen
            if isListMode {
                NotificationCenter.default.post(name: .setSheetLarge, object: nil)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                }
            }
            cameraPosition = .region(mapVM.region)
            filterVM.onCategoryChanged = { categoryId in
                mapVM.onCategorySelected(
                    categoryId: categoryId,
                    allActivities: activityVM.activities
                )
            }
            mapVM.onCategorySelected(
                categoryId: filterVM.selectedCategoryId,
                allActivities: activityVM.activities
            )
        }
        .onChange(of: activityVM.activities) { _, newActivities in
            mapVM.onCategorySelected(
                categoryId: filterVM.selectedCategoryId,
                allActivities: newActivities
            )
        }
        .onChange(of: mapVM.region.center.latitude) { _, _ in
            withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
                cameraPosition = .region(mapVM.region)
            }
        }
        .onChange(of: mapVM.region.center.longitude) { _, _ in
            withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
                cameraPosition = .region(mapVM.region)
            }
        }
    }

    // MARK: Map Layer

    @ViewBuilder
    private var mapLayer: some View {
        let filtered = activityVM.filteredActivities(categoryId: filterVM.selectedCategoryId)

        Map(position: $cameraPosition) {
            ForEach(uniqueLocations) { location in
                Annotation("", coordinate: location.coordinate, anchor: .bottom) {
                    ActivityMapAnnotation(
                        location: location,
                        dominantCategoryId: mapVM.dominantCategoryId(
                            for: location,
                            activities: filtered
                        ),
                        isSelected: mapVM.selectedLocation?.id == location.id,
                        onTap: {
                            mapVM.onPinTapped(
                                location: location,
                                allActivities: activityVM.activities,
                                categoryId: filterVM.selectedCategoryId
                            )
                        }
                    )
                }
            }
        }
        .mapStyle(.standard)
    }

    // MARK: Map Control Buttons (rechts oben, fix)

    @ViewBuilder
    private var mapControlButtons: some View {
        VStack(spacing: 0) {

            // Zoom In
            Button { zoomIn() } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }

            Divider().frame(width: 36)

            // Zoom Out
            Button { zoomOut() } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }

            // Trennlinie zwischen Zoom und GPS
            Color(.systemGray4)
                .frame(width: 36, height: 0.5)
                .padding(.vertical, 4)

            // GPS Refokussierung
            Button { refocusOnGPS() } label: {
                let hasLocation = locationManager.currentLocation != nil
                Image(systemName: hasLocation ? "location.fill" : "location.slash")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(hasLocation ? Color(hex: "#E8593C") : Color(.systemGray3))
                    .frame(width: 36, height: 36)
            }
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }

    // MARK: Zoom + GPS Actions

    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let span = MKCoordinateSpan(
                latitudeDelta:  max(mapVM.region.span.latitudeDelta  * 0.5, 0.002),
                longitudeDelta: max(mapVM.region.span.longitudeDelta * 0.5, 0.002)
            )
            mapVM.region = MKCoordinateRegion(center: mapVM.region.center, span: span)
        }
    }

    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let span = MKCoordinateSpan(
                latitudeDelta:  min(mapVM.region.span.latitudeDelta  * 2.0, 50.0),
                longitudeDelta: min(mapVM.region.span.longitudeDelta * 2.0, 50.0)
            )
            mapVM.region = MKCoordinateRegion(center: mapVM.region.center, span: span)
        }
    }

    private func refocusOnGPS() {
        guard let coordinate = locationManager.currentLocation else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            mapVM.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta:  AppConstants.defaultMapSpan,
                    longitudeDelta: AppConstants.defaultMapSpan
                )
            )
        }
    }
}

// MARK: - Preview

#Preview("Map Screen") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel()
    let filterVM = FilterViewModel()
    let locationManager = LocationManager()

    activityVM.activities = Activity.samples
    mapVM.region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.154, longitude: 11.578),
        span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    )

    return MapScreen()
        .environment(mapVM)
        .environment(filterVM)
        .environment(activityVM)
        .environment(locationManager)
}
