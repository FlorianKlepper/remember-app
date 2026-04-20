// StatsScreen.swift
// ActivityTracker2 — Remember
// Statistik-Dashboard mit Kategorien, Orten und Monatsübersicht

import SwiftUI
import SwiftData

// MARK: - StatsScreen

/// Zeigt aggregierte Statistiken: Kategorien-Top-5, Top-Orte und Monatsübersicht.
/// Erweiterte Stats (vollständige Historie) sind Plus-exklusiv.
struct StatsScreen: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(StatsViewModel.self)     private var statsVM
    @Environment(UserSettings.self)       private var userSettings
    @Environment(StoreKitManager.self)    private var storeKitManager
    @Environment(AnalyticsManager.self)   private var analyticsManager

    @Query private var activities: [Activity]

    private var totalCount: Int { activities.count }

    private var cityCount: Int {
        Set(activities.compactMap { $0.location?.city }).count
    }

    private var bestYear: String {
        let grouped = Dictionary(grouping: activities) { activity -> Int in
            Calendar.current.component(.year, from: activity.date)
        }
        guard let year = grouped.max(by: { $0.value.count < $1.value.count })?.key else {
            return "–"
        }
        return "\(year)"
    }

    private var favoriteCount: Int {
        activities.filter { $0.isFavorite }.count
    }

    private var categoriesUsedCount: Int {
        Set(activities.map { $0.categoryId }).count
    }

    private var isPlusUser: Bool {
        storeKitManager.isPlusActive || userSettings.subscriptionStatus.isPremium
    }

    // MARK: State

    @State private var showSettings = false

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
                        totalCount: totalCount,
                        categoriesUsed: categoriesUsedCount,
                        topCategoryId: topCategory?.id,
                        topCategoryName: topCategory?.name
                    )

                    // ── Section 1b: Emotionale Stats ─────────────────
                    if totalCount > 0 {
                        emotionalStatsCard
                    }

                    // ── Section 2: Nutzung / Limit ───────────────────
                    if !isPlusUser {
                        usageLimitCard
                    }

                    // ── Section 3: Top Kategorien ────────────────────
                    topCategoriesSection

                    // ── Section 3: Top Orte ──────────────────────────
                    topCitiesSection

                    // ── Section 4: Monatsübersicht ───────────────────
                    monthlySection

                    // Puffer — Platz zum Hochscrollen über Tab Bar
                    Color.clear.frame(height: 100)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("stats.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsScreen()
            }
        }
        .onAppear {
            statsVM.compute(from: activityVM.activities)
            analyticsManager.track(.statsOpened)
        }
        .onChange(of: activityVM.activities.count) {
            statsVM.compute(from: activityVM.activities)
        }
    }

    // MARK: Emotional Stats Card

    @ViewBuilder
    private var emotionalStatsCard: some View {
        VStack(spacing: 0) {
            emotionalStatRow(
                icon: "sparkles",
                text: String(format: L10n.statsMoments, activities.count)
            )
            Divider().padding(.leading, 52)
            emotionalStatRow(
                icon: "building.2.fill",
                text: String(format: L10n.statsCities, cityCount)
            )
            Divider().padding(.leading, 52)
            emotionalStatRow(
                icon: "calendar.badge.checkmark",
                text: String(format: L10n.statsBestYear, bestYear)
            )
            if favoriteCount > 0 {
                Divider().padding(.leading, 52)
                emotionalStatRow(
                    icon: "heart.fill",
                    text: String(format: L10n.statsFavorites, favoriteCount)
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.white.opacity(0.5), .clear],
                                     startPoint: .top, endPoint: .center))
                .allowsHitTesting(false)
        )
        .padding(.horizontal, 16)
    }

    private func emotionalStatRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(brandColor)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Usage Limit Card

    @ViewBuilder
    private var usageLimitCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.statsUsageTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(totalCount) / \(AppConstants.freeActivityLimit)")
                    .font(.subheadline)
                    .foregroundStyle(totalCount > 80 ? Color.red : Color.secondary)
            }

            ProgressView(
                value: Double(min(totalCount, AppConstants.freeActivityLimit)),
                total: Double(AppConstants.freeActivityLimit)
            )
            .tint(totalCount > 80 ? .red : Color(hex: "#E8593C"))

            if totalCount > 80 {
                Text(String(format: L10n.statsUsageWarning,
                            AppConstants.freeActivityLimit - totalCount))
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        )
        .padding(.horizontal, 16)
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
                let maxCount = statsVM.topCategories.first?.count ?? 1

                VStack(spacing: 0) {
                    ForEach(statsVM.topCategories) { stat in
                        HStack(spacing: 12) {
                            CategoryIconView(categoryId: stat.id, size: 36)

                            Text(stat.name)
                                .font(.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text("\(stat.count)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: categoryColorHex(for: stat.id)))
                                .frame(width: barWidth(count: stat.count, maxCount: maxCount), height: 6)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if stat.id != statsVM.topCategories.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .allowsHitTesting(false)
                )
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: Category Helpers

    private func categoryColorHex(for id: String) -> String {
        (Category.mvpCategories + Category.plusCategories)
            .first { $0.id == id }?.colorHex ?? "888888"
    }

    private func barWidth(count: Int, maxCount: Int) -> CGFloat {
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return Swift.max(4, ratio * 60)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if city.id != statsVM.topCities.last?.id {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .allowsHitTesting(false)
                )
                .padding(.horizontal, 16)
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

        ScrollViewReader { proxy in
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
                        .id(stat.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onAppear {
                if let last = statsVM.activitiesPerMonth.last {
                    proxy.scrollTo(last.id, anchor: .trailing)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        )
        .padding(.horizontal, 16)
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
        .environment(StoreKitManager())
}
