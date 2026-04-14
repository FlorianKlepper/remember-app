// FilterViewModel.swift
// ActivityTracker2 — Remember
// Globaler Filter-State für Map und Liste

import Foundation

// MARK: - FilterViewModel

/// Verwaltet den globalen Kategorie-Filter.
/// Der Filter gilt synchron für Map UND Liste — kein @MainActor nötig,
/// da keine async-Operationen ausgeführt werden.
@Observable
final class FilterViewModel {

    // MARK: Properties

    /// Aktive Kategorie-ID oder `nil` wenn kein Filter gesetzt (= "Alle").
    var selectedCategoryId: String? = nil

    /// Wird nach jedem Filterwechsel aufgerufen — übergibt die neue `categoryId` oder `nil`.
    /// MapScreen hängt hier die Map-Animations-Logik ein.
    var onCategoryChanged: ((String?) -> Void)?

    // MARK: Init

    init() {}
}

// MARK: - Filter-Steuerung

extension FilterViewModel {

    /// `true` wenn ein Kategorie-Filter aktiv ist.
    var isFilterActive: Bool {
        selectedCategoryId != nil
    }

    /// Setzt den Filter auf eine Kategorie und informiert den `onCategoryChanged`-Callback.
    /// - Parameter categoryId: ID der zu filternden Kategorie.
    func setFilter(categoryId: String) {
        selectedCategoryId = categoryId
        onCategoryChanged?(categoryId)
    }

    /// Setzt den Filter zurück und informiert den `onCategoryChanged`-Callback.
    func clearFilter() {
        selectedCategoryId = nil
        onCategoryChanged?(nil)
    }
}

// MARK: - Kategorie-Helfer

extension FilterViewModel {

    /// Gibt alle Kategorien zurück, die mindestens eine Activity haben.
    /// Sortiert nach Anzahl der Activities absteigend (meistgenutzte Kategorie zuerst).
    /// - Parameter activities: Alle aktuell geladenen Activities.
    /// - Returns: `[Category]` für die CategoryChipBar.
    func sortedUsedCategories(from activities: [Activity]) -> [Category] {
        let allCategories = Category.mvpCategories + Category.plusCategories
        let grouped = Dictionary(grouping: activities, by: { $0.categoryId })

        return allCategories
            .filter { grouped[$0.id] != nil }
            .sorted { (grouped[$0.id]?.count ?? 0) > (grouped[$1.id]?.count ?? 0) }
    }

    /// Gibt die nächste Kategorie in der Swipe-Navigation zurück.
    ///
    /// Kategorien sind intern nach Anzahl absteigend sortiert (wie in der ChipBar).
    /// `direction: +1` bewegt sich vorwärts durch die Liste (Richtung geringere Anzahl).
    /// `direction: -1` bewegt sich rückwärts (Richtung höhere Anzahl).
    /// An den Grenzen wird `nil` zurückgegeben — dies entspricht "Alle anzeigen".
    ///
    /// - Parameters:
    ///   - activities: Alle aktuell sichtbaren Activities.
    ///   - direction: `+1` für aufsteigend (Swipe links), `-1` für absteigend (Swipe rechts).
    /// - Returns: `categoryId` der nächsten Kategorie oder `nil` für "Alle".
    func nextCategory(from activities: [Activity], direction: Int) -> String? {
        let categories = sortedUsedCategories(from: activities)
        guard !categories.isEmpty else { return nil }

        if let currentId = selectedCategoryId,
           let currentIndex = categories.firstIndex(where: { $0.id == currentId }) {
            let nextIndex = currentIndex + direction
            guard categories.indices.contains(nextIndex) else {
                // Grenze erreicht → zurück zu "Alle"
                return nil
            }
            return categories[nextIndex].id
        } else {
            // Aktuell "Alle" — erster Einstieg in die Navigation
            return direction > 0 ? categories.first?.id : categories.last?.id
        }
    }
}
