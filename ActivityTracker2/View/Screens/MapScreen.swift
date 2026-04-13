// MapScreen.swift
// ActivityTracker2 — Remember
// Homescreen der App — interaktive Karte mit Pins und Bottom Sheet

import SwiftUI
import MapKit

// MARK: - MapScreen

/// Startscreen der App. Zeigt alle Activities als Pins auf der Karte.
/// Pin-Tap öffnet das Bottom Sheet mit allen Activities an diesem Ort.
struct MapScreen: View {

    // MARK: Environment

    @Environment(MapViewModel.self)    private var mapVM
    @Environment(FilterViewModel.self) private var filterVM
    @Environment(ActivityViewModel.self) private var activityVM

    // MARK: State

    @State private var showAddFlow    = false
    @State private var showBottomSheet = false
    @State private var cameraPosition: MapCameraPosition = .automatic

    // MARK: Private

    /// Alle einzigartigen Locations der gefilterten Activities.
    private var uniqueLocations: [Location] {
        let filtered = activityVM.filteredActivities(
            categoryId: filterVM.selectedCategoryId
        )
        var seen = Set<UUID>()
        return filtered
            .compactMap { $0.location }
            .filter { seen.insert($0.id).inserted }
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .top) {

            // ── Karte ──────────────────────────────────────────────
            mapLayer
                .ignoresSafeArea()

            // ── Obere UI-Leiste ────────────────────────────────────
            VStack(spacing: 0) {
                CategoryChipBar(
                    filterVM: filterVM,
                    activities: activityVM.activities,
                    language: Locale.current.language.languageCode?.identifier ?? "en"
                )
                .background(.ultraThinMaterial)

                if filterVM.isFilterActive {
                    FilterStatusBanner(
                        filterVM: filterVM,
                        language: Locale.current.language.languageCode?.identifier ?? "en"
                    )
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: AppConstants.animationStandard),
                       value: filterVM.isFilterActive)

            // ── Floating Plus Button ────────────────────────────────
            FloatingPlusButton {
                showAddFlow = true
            }
        }

        // ── Sheet 1: Add Activity Flow ──────────────────────────────
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
                .presentationDetents([.large])
        }

        // ── Sheet 2: Bottom Sheet ───────────────────────────────────
        .sheet(isPresented: $showBottomSheet) {
            ActivityBottomSheet()
                .presentationDetents([
                    .fraction(AppConstants.bottomSheetSmall),
                    .fraction(AppConstants.bottomSheetMedium),
                    .fraction(1.0)
                ])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(AppConstants.bottomSheetMedium)))
        }

        .onAppear {
            cameraPosition = .region(mapVM.region)
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
        let filtered = activityVM.filteredActivities(
            categoryId: filterVM.selectedCategoryId
        )

        Map(position: $cameraPosition) {
            ForEach(uniqueLocations) { location in
                Annotation(
                    "",
                    coordinate: location.coordinate,
                    anchor: .bottom
                ) {
                    ActivityMapAnnotation(
                        location: location,
                        dominantCategoryId: mapVM.dominantCategoryId(
                            for: location,
                            activities: filtered
                        ),
                        isSelected: mapVM.selectedLocation?.id == location.id,
                        onTap: {
                            withAnimation {
                                mapVM.handlePinTap(
                                    location: location,
                                    activities: filtered
                                )
                            }
                            showBottomSheet = true
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

    // Mock-Activities mit Locations eintragen
    activityVM.activities = Activity.samples

    return MapScreen()
        .environment(mapVM)
        .environment(filterVM)
        .environment(activityVM)
}
