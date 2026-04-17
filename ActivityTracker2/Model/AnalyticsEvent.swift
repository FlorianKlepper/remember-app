// AnalyticsEvent.swift
// ActivityTracker2 — Remember
// Typsicheres Enum aller Analytics-Events

import Foundation

// MARK: - AnalyticsEvent

/// Alle vom `AnalyticsManager` verfolgten Events.
enum AnalyticsEvent {

    // MARK: App-Lifecycle

    /// App wird gestartet oder in den Vordergrund gebracht.
    case appOpened

    /// User hat den Onboarding-Flow vollständig abgeschlossen.
    case onboardingCompleted

    // MARK: Activity CRUD

    /// Eine Activity wurde erfolgreich gespeichert.
    /// - Parameter categoryId: ID der gewählten Kategorie.
    case activityCreated(categoryId: String)

    /// Eine Activity wurde gelöscht.
    case activityDeleted

    /// Eine Activity wurde bearbeitet.
    case activityEdited

    // MARK: Filter

    /// Ein Kategorie-Filter wurde aktiviert.
    /// - Parameter categoryId: ID der gefilterten Kategorie.
    case filterApplied(categoryId: String)

    /// Aktiver Filter wurde zurückgesetzt.
    case filterCleared

    // MARK: Map

    /// User hat einen Map-Pin angetippt.
    case pinTapped

    // MARK: Monetarisierung

    /// Plus-Screen wurde angezeigt.
    case plusScreenViewed

    /// Plus wurde erfolgreich gekauft.
    case plusPurchased
}
