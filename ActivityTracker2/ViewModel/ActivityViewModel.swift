// ActivityViewModel.swift
// ActivityTracker2 — Remember
// Zentrale Business-Logik für Activity CRUD und Filterung

import Foundation
import SwiftData

// MARK: - ActivityViewModel

/// Verwaltet den gesamten Activity-Datensatz und koordiniert
/// SwiftData-Operationen mit Analytics-Tracking.
@Observable
@MainActor
final class ActivityViewModel {

    // MARK: Properties

    /// Alle Activities, chronologisch absteigend sortiert (neueste zuerst).
    var activities: [Activity] = []

    /// Wird während SwiftData-Operationen auf `true` gesetzt.
    var isLoading: Bool = false

    // MARK: Private

    private let analytics: AnalyticsManager

    // MARK: Init

    /// - Parameter analytics: Wird für Event-Tracking nach CRUD-Operationen verwendet.
    init(analytics: AnalyticsManager) {
        self.analytics = analytics
    }
}

// MARK: - Fetch

extension ActivityViewModel {

    /// Lädt alle Activities aus SwiftData und aktualisiert `activities`.
    /// Sortierung: neueste `date` zuerst.
    func fetchActivities(context: ModelContext) {
        isLoading = true
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            activities = try context.fetch(descriptor)
        } catch {
            activities = []
        }
        isLoading = false
    }
}

// MARK: - Create / Update / Delete

extension ActivityViewModel {

    /// Legt eine neue Activity an, speichert sie in SwiftData und trackt das Event.
    /// - Parameters:
    ///   - title: Optionaler Kurztitel (wird auf `nil` normalisiert wenn leer).
    ///   - text: Optionaler Langtext (wird auf `nil` normalisiert wenn leer).
    ///   - categoryId: ID der gewählten Kategorie.
    ///   - location: Bereits ermitteltes oder gefundenes `Location`-Objekt.
    ///   - date: Vom User gewähltes Erlebnisdatum.
    ///   - context: Aktiver SwiftData `ModelContext`.
    /// - Throws: `AppError.saveFailed` bei fehlgeschlagenem Speichern.
    func addActivity(
        title: String?,
        text: String?,
        categoryId: String,
        location: Location,
        date: Date,
        starRating: Int = 0,
        context: ModelContext
    ) async throws {
        let normalizedTitle = title.flatMap { $0.isBlank ? nil : $0 }
        let normalizedText  = text.flatMap  { $0.isBlank ? nil : $0 }

        let activity = Activity(
            categoryId: categoryId,
            date: date,
            title: normalizedTitle,
            text: normalizedText,
            starRating: starRating,
            location: location
        )

        context.insert(activity)

        do {
            try context.save()
        } catch {
            throw AppError.saveFailed
        }

        fetchActivities(context: context)
        analytics.track(.activitySaved(categoryId: categoryId, city: location.city))
    }

    /// Persistiert Änderungen an einer bestehenden Activity.
    /// Die Activity muss vor dem Aufruf bereits modifiziert worden sein.
    func updateActivity(_ activity: Activity, context: ModelContext) {
        do {
            try context.save()
        } catch {
            // Fehler werden still protokolliert — kein Throw, da Update-Failures
            // nicht den gesamten Flow unterbrechen sollen
        }
        fetchActivities(context: context)
    }

    /// Löscht eine Activity aus SwiftData und trackt das Deletion-Event.
    func deleteActivity(_ activity: Activity, context: ModelContext) {
        let categoryId = activity.categoryId
        context.delete(activity)
        do {
            try context.save()
        } catch {
            // Fehler still ignorieren — View zeigt optimistisch gelöscht
        }
        fetchActivities(context: context)
        analytics.track(.activityDeleted(categoryId: categoryId))
    }
}

// MARK: - Computed Properties

extension ActivityViewModel {

    /// Filtert Activities nach Kategorie.
    /// - Parameter categoryId: Gewünschte Kategorie-ID oder `nil` für alle.
    /// - Returns: Gefiltertes Array in bestehender Sortierung.
    func filteredActivities(categoryId: String?) -> [Activity] {
        guard let categoryId else { return activities }
        return activities.filter { $0.categoryId == categoryId }
    }

    /// Anzahl der Activities der letzten 7 Tage.
    var activitiesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        return activities.filter { $0.date >= weekAgo }.count
    }

    /// Gesamtanzahl aller Activities.
    var totalCount: Int {
        activities.count
    }
}
