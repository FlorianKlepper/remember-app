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
    @Environment(UserSettings.self)      private var userSettings

    // MARK: State

    @State private var showSettings:        Bool = false
    @State private var currentSheetIsSmall: Bool = true

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

    private var displayedAnnotations: [ActivityAnnotation] {
        mapVM.displayedActivities
            .filter { $0.location != nil }
            .map { activity in
                ActivityAnnotation(
                    activity: activity,
                    isSelected: activity.id == mapVM.highlightedActivityId
                )
            }
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Karte — volle Höhe ────────────────────────────────
            mapLayer
                .ignoresSafeArea()

            // ── Oben: Blur nur über Notch, ChipBar + Controls klar auf Karte ──
            VStack(spacing: 0) {

                // Platzhalter — Höhe = Blur-Bereich (kein sichtbarer Inhalt)
                Color.clear
                    .frame(height: topSafeArea * 1.2)

                // ChipBar — direkt nach Safe Area, kein Blur-Hintergrund
                CategoryChipBar(
                    filterVM: filterVM,
                    activities: activityVM.activities,
                    language: language
                )
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Zoom/GPS rechts + FilterBanner links — unter ChipBar
                HStack(alignment: .top) {
                    if filterVM.isFilterActive {
                        FilterStatusBanner(filterVM: filterVM, language: language)
                            .padding(.leading, 12)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    Spacer()
                    mapControlButtons
                        .padding(.trailing, 12)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .background(
                // Blur NUR über der Safe Area — nicht hinter ChipBar
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: topSafeArea * 1.2)
                        .ignoresSafeArea(edges: .top)
                    Spacer()
                },
                alignment: .top
            )
            .animation(.easeInOut(duration: AppConstants.animationStandard),
                       value: filterVM.isFilterActive)

            // ── Permanenter Bottom Sheet ───────────────────────────
            PermanentBottomSheet(mapVM: mapVM)
                .zIndex(50)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showSettings) {
            SettingsScreen()
        }
        .onAppear {
            // Tab-Modus → Sheet-Position beim Start setzen
            if isListMode {
                NotificationCenter.default.post(name: .setSheetLarge, object: nil)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                }
            }
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
        // Erster GPS-Fix → Karte einmalig auf aktuellen Standort zentrieren
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            guard let coord = newLocation, !mapVM.hasInitialLocation else { return }
            mapVM.hasInitialLocation = true
            mapVM.region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        .onChange(of: activityVM.activities) { _, newActivities in
            mapVM.onCategorySelected(
                categoryId: filterVM.selectedCategoryId,
                allActivities: newActivities
            )
        }
        // GPS-Berechtigung erteilt → Karte auf aktuellen Standort zentrieren
        .onReceive(NotificationCenter.default.publisher(for: .locationPermissionGranted)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let coord = locationManager.currentLocation else { return }
                mapVM.region = MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                mapVM.hasInitialLocation = true
            }
        }
        // Sheet-Größe tracken (von PermanentBottomSheet gesendet)
        .onReceive(NotificationCenter.default.publisher(for: .sheetSizeChanged)) { notification in
            currentSheetIsSmall = notification.object as? Bool ?? true
        }
        // Filter zurücksetzen (von AddActivityTextScreen gesendet)
        .onReceive(NotificationCenter.default.publisher(for: .filterCleared)) { _ in
            withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
                filterVM.clearFilter()
            }
        }
        // Neue Aktivität gespeichert → Karte auf neuen Pin zentrieren
        .onReceive(NotificationCenter.default.publisher(for: .activitySaved)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let newest  = activityVM.activities
                    .sorted(by: { $0.date > $1.date }).first,
                      let location = newest.location
                else { return }

                mapVM.highlightedActivityId = newest.id
                mapVM.selectedLocation      = location

                mapVM.region = MKCoordinateRegion(
                    center: mapVM.adjustedCenter(
                        for: location.coordinate,
                        span: mapVM.region.span,
                        sheetDetent: 0.45
                    ),
                    span: mapVM.region.span
                )
            }
        }
    }

    // MARK: Map Layer

    @ViewBuilder
    private var mapLayer: some View {
        SmoothMapView(
            region: Binding(
                get: { mapVM.region },
                set: { mapVM.region = $0 }
            ),
            annotations: displayedAnnotations,
            mapStyle: userSettings.mapStyle,
            onRegionChange: { newRegion in
                mapVM.region = newRegion
            },
            onAnnotationTap: { annotation in
                mapVM.highlightedActivityId = annotation.activity.id
            }
        )
    }

    // MARK: Map Control Buttons (rechts oben, fix)

    @ViewBuilder
    private var mapControlButtons: some View {
        VStack(spacing: 0) {

            // Einstellungen
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 42, height: 42)
            }

            Color(.systemGray4)
                .frame(width: 42, height: 0.5)
                .padding(.vertical, 4)

            // Zoom In
            Button(action: zoomIn) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .contentShape(Rectangle())
            }

            Divider().frame(width: 42)

            // Zoom Out
            Button(action: zoomOut) {
                Image(systemName: "minus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .contentShape(Rectangle())
            }

            // Trennlinie zwischen Zoom und GPS
            Color(.systemGray4)
                .frame(width: 42, height: 0.5)
                .padding(.vertical, 4)

            // GPS Refokussierung
            Button { refocusOnGPS() } label: {
                let hasLocation = locationManager.currentLocation != nil
                Image(systemName: hasLocation ? "location.fill" : "location.slash")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(hasLocation ? Color(hex: "#E8593C") : Color(.systemGray3))
                    .frame(width: 42, height: 42)
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
        // Kein withAnimation — SmoothMapView animiert via UIView.animate ✓
        mapVM.region = MKCoordinateRegion(
            center: mapVM.region.center,
            span: MKCoordinateSpan(
                latitudeDelta:  max(mapVM.region.span.latitudeDelta  * 0.5, 0.001),
                longitudeDelta: max(mapVM.region.span.longitudeDelta * 0.5, 0.001)
            )
        )
    }

    private func zoomOut() {
        mapVM.region = MKCoordinateRegion(
            center: mapVM.region.center,
            span: MKCoordinateSpan(
                latitudeDelta:  min(mapVM.region.span.latitudeDelta  * 2.0, 100.0),
                longitudeDelta: min(mapVM.region.span.longitudeDelta * 2.0, 100.0)
            )
        )
    }

    private func refocusOnGPS() {
        guard let coordinate = locationManager.currentLocation else { return }
        mapVM.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta:  AppConstants.defaultMapSpan,
                longitudeDelta: AppConstants.defaultMapSpan
            )
        )
    }
}

// MARK: - Preview

#Preview("Map Screen") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel(analytics: analytics)
    let filterVM = FilterViewModel(analytics: analytics)
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
