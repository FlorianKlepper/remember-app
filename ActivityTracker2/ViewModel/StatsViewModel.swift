// StatsViewModel.swift
// ActivityTracker2 — Remember
// Berechnet alle Statistiken aus dem Activity-Datensatz

import Foundation

// MARK: - StatsViewModel

/// Berechnet und hält alle Kennzahlen für den Stats-Tab.
/// Alle Stats werden in `compute(from:)` synchron neu berechnet — kein async nötig.
@Observable
@MainActor
final class StatsViewModel {

    // MARK: Innere Typen

    /// Statistik für eine einzelne Kategorie.
    struct CategoryStat: Identifiable {
        /// Kategorie-ID als eindeutiger Schlüssel.
        let id: String
        /// Lokalisierter Kategoriename (Systemsprache-abhängig).
        let name: String
        /// SF-Symbol-Name des Kategorie-Icons.
        let iconName: String
        /// Anzahl der Activities in dieser Kategorie.
        let count: Int
        /// Prozentualer Anteil an allen Activities (0–100).
        let percentage: Double
    }

    /// Statistik für eine Stadt.
    struct CityStat: Identifiable {
        /// Stadtname als eindeutiger Schlüssel.
        let id: String
        /// Anzeigename der Stadt.
        let name: String
        /// Anzahl der Activities in dieser Stadt.
        let count: Int
    }

    /// Aktivitätsanzahl für einen Kalendermonat.
    struct MonthStat: Identifiable {
        /// Formatierter Monats-String als Schlüssel, z.B. "Jan 2026".
        let id: String
        /// Anzeigename des Monats.
        let month: String
        /// Anzahl der Activities in diesem Monat.
        let count: Int
    }

    // MARK: Berechnete Stats-Properties

    /// Gesamtanzahl aller einbezogenen Activities.
    private(set) var totalActivities: Int = 0

    /// Top-5-Kategorien nach Anzahl absteigend.
    private(set) var topCategories: [CategoryStat] = []

    /// Top-5-Städte nach Anzahl absteigend.
    private(set) var topCities: [CityStat] = []

    /// Activities pro Monat für die letzten 12 Monate (chronologisch aufsteigend).
    private(set) var activitiesPerMonth: [MonthStat] = []

    /// Anzahl der Activities der letzten 7 Tage.
    private(set) var activitiesThisWeek: Int = 0

    // MARK: Init

    init() {}
}

// MARK: - Berechnung

extension StatsViewModel {

    /// Berechnet alle Statistiken neu aus dem übergebenen Activity-Array.
    /// Sollte aufgerufen werden wenn sich `ActivityViewModel.activities` ändert.
    /// - Parameter activities: Alle anzuzeigenden Activities (ungefiltert).
    func compute(from activities: [Activity]) {
        totalActivities = activities.count
        computeTopCategories(from: activities)
        computeTopCities(from: activities)
        computeMonthStats(from: activities)
        computeWeekStats(from: activities)
    }
}

// MARK: - Private Berechnungen

private extension StatsViewModel {

    func computeTopCategories(from activities: [Activity]) {
        let allCategories = Category.mvpCategories + Category.plusCategories
        let grouped = Dictionary(grouping: activities, by: { $0.categoryId })
        let total = activities.count

        let stats: [CategoryStat] = grouped.compactMap { (categoryId, acts) in
            guard let category = allCategories.first(where: { $0.id == categoryId }) else {
                return nil
            }
            let langCode = Locale.current.language.languageCode?.identifier ?? "en"
            let name = langCode == "de" ? category.nameDe : category.nameEn
            let percentage = total > 0
                ? (Double(acts.count) / Double(total)) * 100.0
                : 0.0
            return CategoryStat(
                id: categoryId,
                name: name,
                iconName: category.iconName,
                count: acts.count,
                percentage: percentage
            )
        }
        topCategories = Array(stats.sorted { $0.count > $1.count }.prefix(5))
    }

    func computeTopCities(from activities: [Activity]) {
        let cityNames = activities.compactMap { $0.location?.city }.filter { !$0.isBlank }
        let grouped = Dictionary(grouping: cityNames, by: { $0 })
        let stats = grouped.map { city, items in
            CityStat(id: city, name: city, count: items.count)
        }
        topCities = Array(stats.sorted { $0.count > $1.count }.prefix(5))
    }

    func computeMonthStats(from activities: [Activity]) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")

        var stats: [MonthStat] = []

        for monthOffset in stride(from: 11, through: 0, by: -1) {
            guard let monthDate = calendar.date(
                byAdding: .month,
                value: -monthOffset,
                to: .now
            ) else { continue }

            let key = formatter.string(from: monthDate)
            let count = activities.filter {
                calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month)
            }.count

            stats.append(MonthStat(id: key, month: key, count: count))
        }
        activitiesPerMonth = stats
    }

    func computeWeekStats(from activities: [Activity]) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        activitiesThisWeek = activities.filter { $0.date >= weekAgo }.count
    }
}
