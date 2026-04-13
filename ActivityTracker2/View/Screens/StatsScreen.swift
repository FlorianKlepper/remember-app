// StatsScreen.swift
// ActivityTracker2 — Remember
// Statistik-Dashboard mit Kategorien, Orten und Monatsübersicht

import SwiftUI

// MARK: - StatsScreen

/// Zeigt aggregierte Statistiken: Kategorien-Top-5, Top-Orte und Monatsübersicht.
/// Erweiterte Stats (vollständige Historie) sind Plus-exklusiv.
struct StatsScreen: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(StatsViewModel.self)    private var statsVM
    @Environment(UserSettings.self)      private var userSettings

    // MARK: Private

    private let brandColor = Color(hex: "#E8593C")

    private var languageCode: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    private var topCategory: StatsViewModel.CategoryStat? {
        statsVM.topCategories.first
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Section 1: Zusammenfassung ───────────────────
                    StatsSummaryCard(
                        totalCount: statsVM.totalActivities,
                        thisWeek: statsVM.activitiesThisWeek,
                        topCategoryName: topCategory?.name,
                        topCategoryIcon: topCategory?.iconName
                    )
                    .padding(.horizontal)

                    // ── Section 2: Top Kategorien ────────────────────
                    topCategoriesSection

                    // ── Section 3: Top Orte ──────────────────────────
                    topCitiesSection

                    // ── Section 4: Monatsübersicht ───────────────────
                    monthlySection
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("stats.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            statsVM.compute(from: activityVM.activities)
        }
        .onChange(of: activityVM.activities.count) {
            statsVM.compute(from: activityVM.activities)
        }
    }

    // MARK: Section Views

    @ViewBuilder
    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("stats.categories.title")

            if statsVM.topCategories.isEmpty {
                Text("stats.categories.empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(statsVM.topCategories) { stat in
                            VStack(spacing: 6) {
                                CategoryIconView(categoryId: stat.id, size: 44)

                                Text(stat.name)
                                    .font(.caption)
                                    .lineLimit(1)

                                Text("\(stat.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 68)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var topCitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("stats.cities.title")

            if statsVM.topCities.isEmpty {
                Text("stats.cities.empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(statsVM.topCities) { city in
                        HStack {
                            Text(city.name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(city.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                        if city.id != statsVM.topCities.last?.id {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var monthlySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("stats.monthly.title")

            if statsVM.activitiesPerMonth.allSatisfy({ $0.count == 0 }) {
                Text("stats.monthly.empty")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                barChart
            }
        }
    }

    @ViewBuilder
    private var barChart: some View {
        let maxCount = statsVM.activitiesPerMonth.map(\.count).max() ?? 1
        let maxHeight: CGFloat = 80

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(statsVM.activitiesPerMonth) { stat in
                    let barHeight: CGFloat = maxCount > 0
                        ? max(4, CGFloat(stat.count) / CGFloat(maxCount) * maxHeight)
                        : 4

                    VStack(spacing: 4) {
                        if stat.count > 0 {
                            Text("\(stat.count)")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }

                        RoundedRectangle(cornerRadius: 3)
                            .fill(stat.count > 0 ? brandColor : Color(.systemGray5))
                            .frame(width: 20, height: barHeight)

                        Text(stat.month)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .frame(width: 28)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    // MARK: Helper

    @ViewBuilder
    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.headline)
            .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview("Stats Screen") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let statsVM = StatsViewModel()
    let settings = UserSettings()

    activityVM.activities = Activity.samples
    statsVM.compute(from: Activity.samples)

    return StatsScreen()
        .environment(activityVM)
        .environment(statsVM)
        .environment(settings)
}
