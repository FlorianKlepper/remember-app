// ActivityBottomSheet.swift
// ActivityTracker2 — Remember
// Legacy Bottom Sheet — ersetzt durch PermanentBottomSheet

import SwiftUI

// MARK: - ActivityBottomSheet

/// Horizontale Karten-Galerie aller Activities am getappten Pin.
/// Wird aktuell nicht verwendet — ersetzt durch `PermanentBottomSheet`.
struct ActivityBottomSheet: View {

    // MARK: Environment

    @Environment(MapViewModel.self) private var mapVM

    // MARK: State

    @State private var selectedActivity: Activity? = nil

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Header ─────────────────────────────────────────────
            header

            // ── Liste oder Leer-Zustand ────────────────────────────
            if mapVM.displayedActivities.isEmpty {
                EmptyStateView(config: .filteredNoResults)
                    .frame(height: 180)
            } else {
                activityList
            }

            Spacer()
        }
        .padding(.top, 16)
        .sheet(item: $selectedActivity) { activity in
            NavigationStack {
                ActivityDetailScreen(activity: activity)
            }
        }
    }

    // MARK: Private Views

    @ViewBuilder
    private var header: some View {
        let count = mapVM.displayedActivities.count
        let locationName = mapVM.selectedLocation?.displayName ?? ""

        VStack(alignment: .leading, spacing: 2) {
            if !locationName.isEmpty {
                Text(locationName)
                    .font(.headline)
                    .padding(.horizontal, 16)
            }

            Text("\(count) \(String(localized: count == 1 ? "bottomsheet.activities.count.few" : "bottomsheet.activities", defaultValue: count == 1 ? "Aktivität" : "Aktivitäten"))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var activityList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(mapVM.displayedActivities) { activity in
                    activityRow(activity)
                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    private func activityRow(_ activity: Activity) -> some View {
        let isHighlighted = activity.id == mapVM.highlightedActivityId

        HStack(spacing: 12) {
            CategoryIconView(categoryId: activity.categoryId, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text(activity.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isHighlighted ? Color(.systemGray6) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            mapVM.onActivityTapped(activity)
            selectedActivity = activity
        }
    }
}

// MARK: - Preview

#Preview("Activity Bottom Sheet") {
    let mapVM = MapViewModel()
    mapVM.displayedActivities = Array(Activity.samples.prefix(3))
    mapVM.highlightedActivityId = Activity.samples.first?.id

    return NavigationStack {
        ActivityBottomSheet()
    }
    .environment(mapVM)
}
