// OnboardingViewModel.swift
// ActivityTracker2 — Remember
// Steuert den 3-seitigen Onboarding-Flow

import Foundation

// MARK: - OnboardingViewModel

/// Verwaltet den State des Onboarding-TabViews (3 Screens).
/// Screen 0: App-Wert  |  Screen 1: Privacy  |  Screen 2: Location Permission
@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: Properties

    /// Aktuell sichtbarer Onboarding-Screen (0–2).
    var currentPage: Int = 0

    /// `true` während die Location-Permission-Anfrage läuft.
    var isRequestingPermission: Bool = false

    // MARK: Init

    init() {}
}

// MARK: - Navigation

extension OnboardingViewModel {

    /// Wechselt zum nächsten Onboarding-Screen. Maximaler Wert: 2.
    func nextPage() {
        if currentPage < 2 {
            currentPage += 1
        }
    }

    /// Springt direkt zu Page 2 (Location Permission) — wird vom "Überspringen"-Button
    /// auf Page 0 und 1 aufgerufen. Beendet das Onboarding NICHT vorzeitig.
    func skipToLocationPage() {
        currentPage = 2
    }
}

// MARK: - Location Permission

extension OnboardingViewModel {

    /// Fordert die "While Using App"-Location-Berechtigung an.
    /// Wartet nicht auf das Ergebnis — der Autorisierungsstatus wird via
    /// `LocationManager.authorizationStatus` asynchron aktualisiert.
    /// - Parameter manager: Der App-weite `LocationManager`.
    func requestLocationPermission(manager: LocationManager) async {
        isRequestingPermission = true
        manager.requestPermission()
        isRequestingPermission = false
    }
}

// MARK: - Abschluss

extension OnboardingViewModel {

    /// Schließt das Onboarding vollständig ab und speichert die Sprachauswahl.
    /// Wird auf dem letzten Onboarding-Screen aufgerufen.
    /// - Parameters:
    ///   - settings: Globales `UserSettings`-Objekt.
    ///   - language: Gewählter Sprachcode (`"system"`, `"de"`, `"en"`).
    func completeOnboarding(settings: UserSettings, language: String) {
        settings.selectedLanguage = language
        settings.hasCompletedOnboarding = true
    }
}
