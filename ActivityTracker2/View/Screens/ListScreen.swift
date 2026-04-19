// ListScreen.swift
// ActivityTracker2 — Remember
// Chronologische Aktivitätsliste mit Swipe-Kategorie-Navigation

import SwiftUI

// MARK: - ListScreen

/// Listenansicht aller Activities, chronologisch absteigend sortiert.
/// Horizontaler Swipe wechselt die aktive Kategorie — kein Swipe-to-Delete.
struct ListScreen: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(FilterViewModel.self)    private var filterVM

    // MARK: State

    @State private var selectedActivity: Activity? = nil

    // MARK: Private

    private var filteredActivities: [Activity] {
        activityVM.filteredActivities(categoryId: filterVM.selectedCategoryId)
    }

    private var languageCode: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Chip-Leiste ──────────────────────────────────────
                CategoryChipBar(
                    filterVM: filterVM,
                    activities: activityVM.activities,
                    language: languageCode
                )
                .background(.background)

                // ── Filter-Banner ────────────────────────────────────
                if filterVM.isFilterActive {
                    FilterStatusBanner(
                        filterVM: filterVM,
                        language: languageCode
                    )
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // ── Liste oder Leer-Zustand ──────────────────────────
                if filteredActivities.isEmpty {
                    emptyState
                } else {
                    activityList
                }
            }
            .animation(.easeInOut(duration: AppConstants.animationStandard),
                       value: filterVM.isFilterActive)
            .navigationTitle("list.title")
            .navigationBarTitleDisplayMode(.inline)

            // ── Detail-Navigation ────────────────────────────────────
            .navigationDestination(item: $selectedActivity) { activity in
                ActivityDetailScreen(activity: activity)
            }
        }
        .gesture(swipeGesture)
    }

    // MARK: Private Views

    @ViewBuilder
    private var activityList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(
                    Array(filteredActivities.enumerated()),
                    id: \.element.id
                ) { index, activity in
                    let showYearHeader: Bool = {
                        if index == 0 { return true }
                        return filteredActivities[index - 1].yearInt != activity.yearInt
                    }()

                    if showYearHeader {
                        HStack(spacing: 0) {
                            Text(String(format: "%d", activity.yearInt))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.leading, 16)
                                .padding(.vertical, 6)
                            Spacer()
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 0.5)
                                .padding(.trailing, 16)
                        }
                        .background(Color(.systemGray6).opacity(0.5))
                    }

                    Button {
                        selectedActivity = activity
                    } label: {
                        ActivityRowView(activity: activity) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filterVM.setFilter(categoryId: activity.categoryId)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if filterVM.isFilterActive {
            EmptyStateView(config: .filteredNoResults)
        } else {
            EmptyStateView(config: .noActivities)
        }
    }

    // MARK: Swipe-Geste

    /// Horizontaler Swipe wechselt die aktive Kategorie.
    /// Vertikale Gesten werden ignoriert (ScrollView übernimmt).
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical   = abs(value.translation.height)

                // Nur auslösen wenn primär horizontal
                guard abs(horizontal) > vertical else { return }

                if horizontal < -50 {
                    // Swipe links → nächste Kategorie (aufsteigend)
                    applyNextCategory(direction: +1)
                } else if horizontal > 50 {
                    // Swipe rechts → vorherige Kategorie (absteigend)
                    applyNextCategory(direction: -1)
                }
            }
    }

    private func applyNextCategory(direction: Int) {
        withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
            if let nextId = filterVM.nextCategory(
                from: activityVM.activities,
                direction: direction
            ) {
                filterVM.setFilter(categoryId: nextId)
            } else {
                filterVM.clearFilter()
            }
        }
        HapticManager.selectionChanged()
    }
}

// MARK: - Preview

#Preview("List Screen") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let filterVM = FilterViewModel(analytics: analytics)

    activityVM.activities = Activity.samples

    return ListScreen()
        .environment(activityVM)
        .environment(filterVM)
}
