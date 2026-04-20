// UserSettings.swift
// ActivityTracker2 — Remember
// Persistente App-Einstellungen via @AppStorage (UserDefaults)

import Foundation
import SwiftUI
import CoreLocation

// MARK: - UserSettings

/// Zentrales Settings-Objekt der App.
/// Alle Werte werden in UserDefaults persistiert — kein SwiftData.
/// Wird in `ActivityTracker2App` erstellt und per `.environment()` in den View-Tree injiziert.
///
/// > Hinweis: Home-Location-Properties (`homeLatitude`, `homeLongitude`, `homeName`) sind
/// > bewusst NICHT `@ObservationIgnored`, damit `@Observable` sie trackt und Views automatisch
/// > neu rendern wenn sich die Zuhause-Location ändert. Persistenz erfolgt via `didSet`.
/// > Alle anderen `@AppStorage`-Properties bleiben `@ObservationIgnored`, da sie
/// > seltener wechseln und SwiftUI Updates über den UserDefaults-Mechanismus erhält.
@Observable
final class UserSettings {

    // MARK: Home Location — @Observable tracked (kein @ObservationIgnored)

    /// Gespeicherte Heimat-Latitude. `nil` = nicht gesetzt.
    var homeLatitude: Double? = nil {
        didSet {
            if let lat = homeLatitude {
                UserDefaults.standard.set(lat, forKey: "homeLatitude")
            } else {
                UserDefaults.standard.removeObject(forKey: "homeLatitude")
            }
        }
    }

    /// Gespeicherte Heimat-Longitude. `nil` = nicht gesetzt.
    var homeLongitude: Double? = nil {
        didSet {
            if let lon = homeLongitude {
                UserDefaults.standard.set(lon, forKey: "homeLongitude")
            } else {
                UserDefaults.standard.removeObject(forKey: "homeLongitude")
            }
        }
    }

    /// Anzeigename der Heimat-Location, z.B. "München, Maxvorstadt". `nil` = nicht gesetzt.
    var homeName: String? = nil {
        didSet {
            if let name = homeName {
                UserDefaults.standard.set(name, forKey: "homeName")
            } else {
                UserDefaults.standard.removeObject(forKey: "homeName")
            }
        }
    }

    // MARK: Subscription

    /// Interner Rohwert für `subscriptionStatus` — direkt in UserDefaults gespeichert.
    @ObservationIgnored
    @AppStorage("subscriptionStatusRaw") private var subscriptionStatusRaw: String = SubscriptionStatus.free.rawValue

    /// Aktueller Abo-/Kaufstatus des Users.
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
    @ObservationIgnored
    @AppStorage("activitiesCreatedCount") var activitiesCreatedCount: Int = 0

    // MARK: Init

    init() {
        // Onboarding-Status
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        // Home Location laden — Migration: alter Sentinel-Wert -999.0 → nil
        let storedLat = UserDefaults.standard.object(forKey: "homeLatitude") as? Double
        let storedLon = UserDefaults.standard.object(forKey: "homeLongitude") as? Double
        homeLatitude  = (storedLat == nil || storedLat == -999.0) ? nil : storedLat
        homeLongitude = (storedLon == nil || storedLon == -999.0) ? nil : storedLon

        // homeName laden — liest auch alten Key "homeLocationName" für Migration
        homeName = UserDefaults.standard.string(forKey: "homeName")
            ?? UserDefaults.standard.string(forKey: "homeLocationName")
    }
}

// MARK: - Computed Properties

extension UserSettings {

    /// `true` wenn eine Heimat-Location gespeichert ist.
    var hasHomeLocation: Bool {
        homeLatitude != nil && homeLongitude != nil
    }

    /// `CLLocationCoordinate2D` der Heimat-Location, oder `nil` wenn nicht gesetzt.
    var homeCoordinate: CLLocationCoordinate2D? {
        guard let lat = homeLatitude, let lon = homeLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Methoden

extension UserSettings {

    /// Speichert eine neue Heimat-Location.
    func setHomeLocation(coordinate: CLLocationCoordinate2D, name: String) {
        homeLatitude  = coordinate.latitude
        homeLongitude = coordinate.longitude
        homeName      = name
    }

    /// Entfernt die gespeicherte Heimat-Location.
    func clearHomeLocation() {
        homeLatitude  = nil
        homeLongitude = nil
        homeName      = nil
    }

    /// Inkrementiert den Activity-Zähler um 1.
    func incrementActivityCount() {
        activitiesCreatedCount += 1
    }
}
