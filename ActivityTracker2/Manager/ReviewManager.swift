// ReviewManager.swift
// ActivityTracker2 — Remember
// Steuert In-App Review Prompts — smart getimed, nie aufdringlich

import SwiftUI
import StoreKit

// MARK: - ReviewManager

/// Singleton — verwaltet die gesamte Logik wann der Review-Prompt erscheint.
/// Alle Trigger-Bedingungen müssen gleichzeitig erfüllt sein.
@Observable
@MainActor
final class ReviewManager {

    // MARK: Singleton

    static let shared = ReviewManager()

    private init() {}

    // MARK: Published State

    /// Steuert die Anzeige des Pre-Review-Sheets.
    var showPreReviewSheet: Bool = false

    // MARK: UserDefaults Keys

    private enum Keys {
        static let lastPromptDate    = "lastReviewPromptDate"
        static let lastReviewedVersion = "lastReviewedVersion"
        static let statsScreenVisits = "statsScreenVisits"
    }

    // MARK: Computed — UserDefaults

    private var lastPromptDate: Date? {
        get { UserDefaults.standard.object(forKey: Keys.lastPromptDate) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastPromptDate) }
    }

    private var lastReviewedVersion: String {
        get { UserDefaults.standard.string(forKey: Keys.lastReviewedVersion) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastReviewedVersion) }
    }

    private var statsScreenVisits: Int {
        get { UserDefaults.standard.integer(forKey: Keys.statsScreenVisits) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.statsScreenVisits) }
    }

    // MARK: Helpers

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var daysSinceLastPrompt: Int {
        guard let last = lastPromptDate else { return Int.max }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? Int.max
    }

    // MARK: Public API

    /// Prüft ob alle Bedingungen erfüllt sind und zeigt ggf. das Pre-Review-Sheet.
    /// Wird in `.onAppear` des Stats-Screens aufgerufen.
    func checkAndTriggerReview(activityCount: Int) {
        // Besuchszähler erhöhen
        statsScreenVisits += 1

        guard shouldShowReview(activityCount: activityCount) else { return }

        // 1.5s Delay — Stats-Screen soll erst vollständig geladen sein
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showPreReviewSheet = true
        }
    }

    /// Zeigt Apple's nativen Review-Dialog und merkt sich Datum + Version.
    func triggerSystemReview() {
        lastPromptDate    = Date()
        lastReviewedVersion = currentAppVersion

        guard let scene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        SKStoreReviewController.requestReview(in: scene)
    }

    /// Öffnet Feedback-Mail an den Entwickler.
    func openFeedbackMail() {
        lastPromptDate = Date()   // auch bei negativem Feedback Cooldown setzen
        guard let url = URL(string: "mailto:florian@remember-journal.com?subject=Remember%20Feedback") else { return }
        UIApplication.shared.open(url)
    }

    // MARK: Private

    private func shouldShowReview(activityCount: Int) -> Bool {
        guard activityCount >= 5 else { return false }           // mindestens 5 Aktivitäten
        guard statsScreenVisits >= 2 else { return false }       // nicht beim ersten Besuch
        guard lastReviewedVersion != currentAppVersion else { return false } // Version noch nicht reviewed
        guard daysSinceLastPrompt >= 120 else { return false }   // 120-Tage-Cooldown
        return true
    }

    // MARK: Debug

    #if DEBUG
    /// Setzt alle UserDefaults Keys zurück — nur für Testzwecke.
    func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: Keys.lastPromptDate)
        UserDefaults.standard.removeObject(forKey: Keys.lastReviewedVersion)
        UserDefaults.standard.removeObject(forKey: Keys.statsScreenVisits)
        print("[ReviewManager] Alle Keys zurückgesetzt — nächster Stats-Visit triggert ggf. Sheet")
    }
    #endif
}
