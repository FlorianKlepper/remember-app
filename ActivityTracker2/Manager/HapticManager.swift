// HapticManager.swift
// ActivityTracker2 — Remember
// Stateless Haptic-Feedback-Wrapper via UIKit Feedback-Generatoren

import UIKit

// MARK: - HapticManager

/// Stateless Helfer für Haptic Feedback.
/// Nicht instanziierbar — alle Methoden sind statisch.
/// Nutzt `UINotificationFeedbackGenerator` und `UIImpactFeedbackGenerator` aus UIKit.
enum HapticManager {

    // MARK: Notification Feedback

    /// Erfolgreiches Feedback — z.B. nach dem Speichern einer Activity.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Fehler-Feedback — z.B. bei fehlgeschlagenem Kauf oder Validierungsfehler.
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: Impact Feedback

    /// Leichtes Impact-Feedback — z.B. beim Tippen auf Chips oder kleine Buttons.
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium Impact-Feedback — z.B. beim Öffnen eines Sheets oder Modal.
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: Selection Feedback

    /// Selection-Feedback — z.B. beim Wechseln zwischen Kategorie-Chips oder Tabs.
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
