// ActivityBottomSheet.swift
// ActivityTracker2 — Remember
// Bottom Sheet — horizontale Karten-Ansicht aller Activities am getappten Pin

import SwiftUI

// MARK: - ActivityBottomSheet

/// Zeigt alle Activities am zuletzt getappten Map-Pin als horizontale Karten-Galerie.
/// Beim Scrollen wird der aktive Map-Pin via `mapVM.syncMapToScroll` nachgeführt.
struct ActivityBottomSheet: View {

    // MARK: Environment

    @Environment(MapViewModel.self) private var mapVM

    // MARK: State

    /// ID der Activity, die aktuell im ScrollView sichtbar ist (iOS 17 scrollPosition API).
    @State private var scrolledActivityId: Activity.ID?

    /// Ausgewählte Activity für Detail-Navigation.
    @State private var selectedActivity: Activity? = nil

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Header ─────────────────────────────────────────────
            header

            // ── Karten-Galerie oder Leer-Zustand ───────────────────
            if mapVM.activitiesAtPin.isEmpty {
                EmptyStateView(config: .filteredNoResults)
                    .frame(height: 180)
            } else {
                cardGallery
            }

            Spacer()
        }
        .padding(.top, 16)

        // ── Detail-Navigation (Batch 6: ActivityDetailScreen) ───────
        .navigationDestination(item: $selectedActivity) { activity in
            // TODO: Batch 6 — ActivityDetailScreen(activity: activity)
            Text(activity.displayTitle)
        }

        // ── Scroll → Map-Sync ───────────────────────────────────────
        .onChange(of: scrolledActivityId) { _, newId in
            guard let newId,
                  let index = mapVM.activitiesAtPin.firstIndex(where: { $0.id == newId })
            else { return }
            mapVM.syncMapToScroll(index: index)
        }
    }

    // MARK: Private Views

    @ViewBuilder
    private var header: some View {
        let count = mapVM.activitiesAtPin.count
        let locationName = mapVM.selectedLocation?.displayName ?? ""

        VStack(alignment: .leading, spacing: 2) {
            if !locationName.isEmpty {
                Text(locationName)
                    .font(.headline)
                    .padding(.horizontal, 16)
            }

            Text("\(count) \(String(localized: count == 1 ? "bottomsheet.activity.singular" : "bottomsheet.activity.plural", defaultValue: count == 1 ? "Aktivität" : "Aktivitäten"))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var cardGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(Array(mapVM.activitiesAtPin.enumerated()), id: \.element.id) { index, activity in
                    ActivityCardView(
                        activity: activity,
                        isSelected: index == mapVM.selectedActivityIndex
                    )
                    .id(activity.id)
                    .onTapGesture {
                        mapVM.syncMapToScroll(index: index)
                        selectedActivity = activity
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .scrollPosition(id: $scrolledActivityId)
        .scrollTargetBehavior(.viewAligned)

        // Programmatisches Scrollen wenn Map-Pin von außen wechselt
        .onChange(of: mapVM.selectedActivityIndex) { _, newIndex in
            guard mapVM.activitiesAtPin.indices.contains(newIndex) else { return }
            let targetId = mapVM.activitiesAtPin[newIndex].id
            withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
                scrolledActivityId = targetId
            }
        }
    }
}

// MARK: - Preview

#Preview("Activity Bottom Sheet") {
    let mapVM = MapViewModel()
    let samples = Activity.samples
    mapVM.activitiesAtPin = samples
    mapVM.selectedLocation = samples.first?.location
    mapVM.selectedActivityIndex = 0

    return NavigationStack {
        ActivityBottomSheet()
    }
    .environment(mapVM)
    .presentationDetents([
        .fraction(AppConstants.bottomSheetSmall),
        .fraction(AppConstants.bottomSheetMedium),
        .fraction(1.0)
    ])
}
