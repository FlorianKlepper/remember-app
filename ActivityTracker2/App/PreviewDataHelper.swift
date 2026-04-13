// PreviewDataHelper.swift
// ActivityTracker2 — Remember
// Befüllt SwiftData im Debug-Modus mit Münchner Sample-Daten

#if DEBUG

import Foundation
import SwiftData

// MARK: - PreviewDataHelper

/// Fügt beim ersten App-Start im Debug-Modus die 5 Münchner Sample-Activities
/// in SwiftData ein. Wird nur ausgeführt wenn der Store vollständig leer ist.
///
/// Aufruf: `PreviewDataHelper.insertSampleDataIfNeeded(context: modelContext)`
/// — einmalig in `ContentView.onAppear`, vor `activityVM.fetchActivities`.
enum PreviewDataHelper {

    /// Prüft ob SwiftData leer ist und fügt ggf. Sample-Daten ein.
    /// - Parameter context: Aktiver `ModelContext` aus `@Environment(\.modelContext)`.
    static func insertSampleDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Activity>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        // Activity.samples enthält je eine Activity pro Münchner Location.
        // SwiftData folgt der Location-Relation und persistiert beide Objekte.
        Activity.samples.forEach { context.insert($0) }
        try? context.save()
    }
}

#endif
