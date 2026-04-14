// MapScreen.swift
// ActivityTracker2 — Remember
// Homescreen der App — interaktive Karte mit permanentem Bottom Sheet

import SwiftUI
import MapKit

// MARK: - MapScreen

/// Startscreen der App. Zeigt alle Activities als Pins auf der Karte.
/// Das `PermanentBottomSheet` ist IMMER sichtbar — mindestens 15 % Höhe.
/// Pin-Tap → Sheet springt automatisch auf 50 %.
struct MapScreen: View {

    // MARK: Environment

    @Environment(MapViewModel.self)      private var mapVM
    @Environment(FilterViewModel.self)   private var filterVM
    @Environment(ActivityViewModel.self) private var activityVM

    // MARK: State

    @State private var cameraPosition: MapCameraPosition = .automatic

    // MARK: Private

    private var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    /// Alle einzigartigen Locations der gefilterten Activities.
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

            // ── Overlays oben ─────────────────────────────────────
            VStack(spacing: 0) {
                CategoryChipBar(
                    filterVM: filterVM,
                    activities: activityVM.activities,
                    language: language
                )
                .background(.ultraThinMaterial)

                if filterVM.isFilterActive {
                    FilterStatusBanner(filterVM: filterVM, language: language)
                        .padding(.top, 4)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                Spacer()
            }
            .animation(.easeInOut(duration: AppConstants.animationStandard),
                       value: filterVM.isFilterActive)

            // ── Permanenter Bottom Sheet — NIEMALS schließbar ────
            PermanentBottomSheet(mapVM: mapVM)
        }
        .ignoresSafeArea(edges: .bottom)

        .onAppear {
            cameraPosition = .region(mapVM.region)
            // Callback: Chip-Tap → Liste + Map aktualisieren
            filterVM.onCategoryChanged = { categoryId in
                mapVM.onCategorySelected(
                    categoryId: categoryId,
                    allActivities: activityVM.activities
                )
            }
            // Initiale Liste befüllen (Activities könnten bereits geladen sein)
            mapVM.onCategorySelected(
                categoryId: filterVM.selectedCategoryId,
                allActivities: activityVM.activities
            )
        }
        // Activities nachgeladen → Liste aktualisieren
        .onChange(of: activityVM.activities) { _, newActivities in
            mapVM.onCategorySelected(
                categoryId: filterVM.selectedCategoryId,
                allActivities: newActivities
            )
        }
        // MKCoordinateRegion ist nicht Equatable — center und span separat tracken
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
}

// MARK: - Preview

#Preview("Map Screen") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel()
    let filterVM = FilterViewModel()

    activityVM.activities = Activity.samples

    mapVM.region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.154, longitude: 11.578),
        span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    )

    return MapScreen()
        .environment(mapVM)
        .environment(filterVM)
        .environment(activityVM)
}
