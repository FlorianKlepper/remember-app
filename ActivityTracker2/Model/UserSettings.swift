// UserSettings.swift
// ActivityTracker2 — Remember
// Persistente App-Einstellungen via @AppStorage (UserDefaults)

import Foundation
import SwiftUI
import CoreLocation

// MARK: - UserSettings

/// Zentrales Settings-Objekt der App.
/// Alle Werte werden via `@AppStorage` in UserDefaults persistiert — kein SwiftData.
/// Wird in `ActivityTracker2App` erstellt und per `.environment()` in den View-Tree injiziert.
///
/// > Hinweis: `@AppStorage`-Properties innerhalb einer `@Observable`-Klasse
/// > erfordern `@ObservationIgnored`, um Konflikte mit dem Observation-Registrar zu vermeiden.
/// > SwiftUI-Views erhalten Updates weiterhin über den `@AppStorage`-eigenen
/// > UserDefaults-Notification-Mechanismus.
@Observable
final class UserSettings {

    // MARK: Init

    /// Lädt `hasCompletedOnboarding` aus UserDefaults — alle anderen Properties
    /// werden via @AppStorage automatisch synchronisiert.
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    // MARK: Home Location

    /// Gespeicherte Heimat-Latitude. Sentinel `-999.0` bedeutet: nicht gesetzt.
    @ObservationIgnored
    @AppStorage("homeLatitude") var homeLatitude: Double = -999.0

    /// Gespeicherte Heimat-Longitude. Sentinel `-999.0` bedeutet: nicht gesetzt.
    @ObservationIgnored
    @AppStorage("homeLongitude") var homeLongitude: Double = -999.0

    /// Anzeigename der Heimat-Location, z.B. "München, Maxvorstadt".
    @ObservationIgnored
    @AppStorage("homeLocationName") var homeLocationName: String = ""

    // MARK: Subscription

    /// Interner Rohwert für `subscriptionStatus` — direkt in UserDefaults gespeichert.
    @ObservationIgnored
    @AppStorage("subscriptionStatusRaw") private var subscriptionStatusRaw: String = SubscriptionStatus.free.rawValue

    /// Aktueller Abo-/Kaufstatus des Users.
    /// Getter und Setter delegieren an `subscriptionStatusRaw`.
    var subscriptionStatus: SubscriptionStatus {
        get { SubscriptionStatus(rawValue: subscriptionStatusRaw) ?? .free }
        set { subscriptionStatusRaw = newValue.rawValue }
    }

    // MARK: Sprache

    /// Gewählte App-Sprache. Mögliche Werte: `"system"`, `"de"`, `"en"`.
    @ObservationIgnored
    @AppStorage("selectedLanguage") var selectedLanguage: String = "system"

    // MARK: Darstellung

    /// App-weites Farbschema. Werte: `"system"`, `"light"`, `"dark"`.
    @ObservationIgnored
    @AppStorage("colorScheme") var colorScheme: String = "system"

    /// Karten-Stil. Werte: `"standard"`, `"satellite"`, `"hybrid"`.
    @ObservationIgnored
    @AppStorage("mapStyle") var mapStyle: String = "standard"

    // MARK: Onboarding & Paywall

    /// `true` wenn der User das Onboarding abgeschlossen hat.
    /// Kein @ObservationIgnored — muss @Observable-tracked sein damit
    /// ActivityTracker2App.body beim Wechsel OnboardingScreen → ContentView re-rendert.
    var hasCompletedOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    /// `true` wenn die Paywall dem User bereits mindestens einmal angezeigt wurde.
    @ObservationIgnored
    @AppStorage("hasSeenPaywall") var hasSeenPaywall: Bool = false

    // MARK: Aktivitäten-Zähler

    /// Gesamtanzahl erstellter Activities — für Paywall-Trigger-Logik.
    /// Wird bei jedem Speichern inkrementiert, nicht aus SwiftData gezählt.
    @ObservationIgnored
    @AppStorage("activitiesCreatedCount") var activitiesCreatedCount: Int = 0
}

// MARK: - Computed Properties

extension UserSettings {

    /// `true` wenn eine Heimat-Location gespeichert ist (Sentinel-Prüfung).
    var hasHomeLocation: Bool {
        homeLatitude != -999.0
    }

    /// `CLLocationCoordinate2D` der Heimat-Location, oder `nil` wenn nicht gesetzt.
    var homeCoordinate: CLLocationCoordinate2D? {
        guard hasHomeLocation else { return nil }
        return CLLocationCoordinate2D(latitude: homeLatitude, longitude: homeLongitude)
    }
}

// MARK: - Methoden

extension UserSettings {

    /// Speichert eine neue Heimat-Location.
    /// - Parameters:
    ///   - coordinate: Koordinate des Heimat-Orts.
    ///   - name: Menschenlesbarer Anzeigename, z.B. "München, Maxvorstadt".
    func setHomeLocation(coordinate: CLLocationCoordinate2D, name: String) {
        homeLatitude = coordinate.latitude
        homeLongitude = coordinate.longitude
        homeLocationName = name
    }

    /// Entfernt die gespeicherte Heimat-Location und setzt alle Felder zurück.
    func clearHomeLocation() {
        homeLatitude = -999.0
        homeLongitude = -999.0
        homeLocationName = ""
    }

    /// Inkrementiert den Activity-Zähler um 1. Aufruf nach jedem erfolgreichen Speichern.
    func incrementActivityCount() {
        activitiesCreatedCount += 1
    }
}
