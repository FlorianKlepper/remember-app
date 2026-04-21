// L10n.swift
// ActivityTracker2 — Remember
// Lokalisierung ohne Abhängigkeit von Localizable.xcstrings-Einträgen.
// Neue Sprache: isDe-Check durch Tabelle ersetzen.

import Foundation

// MARK: - L10n

/// Statisches Lokalisierungs-Enum — kein xcstrings-Catalog nötig.
enum L10n {

    // MARK: Private Helper

    private static var isDe: Bool {
        Locale.current.language.languageCode?.identifier == "de"
    }

    // MARK: Limit Reached Sheet

    static var limitTitle: String {
        isDe ? "Limit erreicht" : "Limit reached"
    }

    static var limitSubtitle: String {
        isDe
            ? "Du hast 100 Aktivitäten erstellt — das Maximum im kostenlosen Plan."
            : "You've created 100 activities — the maximum in the free plan."
    }

    static var limitFeatureUnlimited: String {
        isDe ? "Unbegrenzte Aktivitäten" : "Unlimited activities"
    }

    static var limitFeatureCategories: String {
        isDe ? "Alle 100 Kategorien freischalten" : "Unlock all 100 categories"
    }

    static var limitFeatureOnetime: String {
        isDe ? "Einmalig kaufen — kein Abo" : "One-time purchase — no subscription"
    }

    static var limitCta: String {
        isDe ? "Remember Plus — 4,99€" : "Remember Plus — €4.99"
    }

    static var limitLater: String {
        isDe ? "Vielleicht später" : "Maybe later"
    }

    // MARK: Plus Screen

    static var plusTitle: String { "Remember Plus" }

    static var plusSubtitle: String {
        isDe ? "Kein Moment geht verloren" : "No moment gets lost"
    }

    static var plusFeatureUnlimited: String {
        isDe ? "Unbegrenzte Erinnerungen" : "Unlimited memories"
    }

    static var plusFeatureCategories: String {
        isDe ? "Alle 100 Kategorien" : "All 100 categories"
    }

    static var plusFeatureOnetime: String {
        isDe ? "Einmalig kaufen — kein Abo" : "One-time purchase — no subscription"
    }

    static var plusFeaturePrivacy: String {
        isDe ? "Keine Werbung · Kein Tracking" : "No ads · No tracking"
    }

    static var plusPrice: String {
        isDe ? "4,99€ — einmalig" : "€4.99 — one-time"
    }

    static var plusLaunchPrice: String {
        isDe ? "Regulär 8,99€ — Launch-Preis!" : "Regular €8.99 — Launch price!"
    }

    static var plusCta: String {
        isDe ? "Alle Momente festhalten" : "Capture every moment"
    }

    static var plusRestore: String {
        isDe ? "Kauf wiederherstellen" : "Restore purchase"
    }

    // MARK: Stats — Usage Card

    static var statsUsageTitle: String {
        isDe ? "Aktivitäten" : "Activities"
    }

    /// Format-String mit %lld — Verwendung: String(format: L10n.statsUsageWarning, remaining)
    static var statsUsageWarning: String {
        isDe ? "Nur noch %lld Aktivitäten verfügbar" : "Only %lld activities remaining"
    }

    // MARK: Stats — Emotional Card

    /// Format-String mit %lld — Verwendung: String(format: L10n.statsMoments, count)
    static var statsMoments: String {
        isDe ? "%lld Momente festgehalten" : "%lld moments captured"
    }

    /// Format-String mit %lld — Verwendung: String(format: L10n.statsCities, cityCount)
    static var statsCities: String {
        isDe ? "Du warst in %lld Städten" : "You've been to %lld cities"
    }

    /// Format-String mit %@ — Verwendung: String(format: L10n.statsBestYear, year)
    static var statsBestYear: String {
        isDe ? "Aktivstes Jahr: %@" : "Most active year: %@"
    }

    /// Format-String mit %lld — Verwendung: String(format: L10n.statsFavorites, count)
    static var statsFavorites: String {
        isDe ? "%lld unvergessliche Momente" : "%lld unforgettable moments"
    }

    static var statsTotal: String {
        isDe ? "Aktivitäten gesamt" : "Total activities"
    }

    // MARK: Categories

    static var categoryUsed: String {
        isDe ? "Verwendete Kategorien" : "Recently Used"
    }

    // MARK: Made in Munich

    static var indieApp: String { "Indie App" }

    static var madeIn: String {
        isDe
            ? "Entwickelt & programmiert\nin München, Deutschland"
            : "Developed & built\nin Munich, Germany"
    }

    static var privacyFooter: String {
        isDe
            ? "Keine Werbung · Kein Tracking\nDeine Daten gehören dir"
            : "No ads · No tracking\nYour data belongs to you"
    }

    // MARK: Settings

    static var settingsTitle: String {
        isDe ? "Einstellungen" : "Settings"
    }

    static var settingsMembership: String {
        isDe ? "Mitgliedschaft" : "Membership"
    }

    static var settingsCurrentPlan: String {
        isDe ? "Aktueller Plan" : "Current Plan"
    }

    static var settingsFree: String {
        isDe ? "Kostenlos" : "Free"
    }

    static var settingsPlus: String { "Plus ✓" }

    static var settingsDiscoverPlus: String {
        isDe ? "Remember Plus entdecken" : "Discover Remember Plus"
    }

    static var settingsActivities: String {
        isDe ? "Aktivitäten verwendet" : "Activities used"
    }

    /// Format-String mit %lld — Verwendung: String(format: L10n.settingsActivitiesCount, count)
    static var settingsActivitiesCount: String {
        isDe ? "%lld Aktivitäten" : "%lld activities"
    }

    static var settingsAppearance: String {
        isDe ? "Darstellung" : "Appearance"
    }

    static var settingsAppearanceMode: String {
        isDe ? "Erscheinungsbild" : "Color Scheme"
    }

    static var settingsSystem: String { isDe ? "System" : "System" }
    static var settingsLight:  String { isDe ? "Hell"   : "Light"  }
    static var settingsDark:   String { isDe ? "Dunkel" : "Dark"   }

    static var settingsMapStyle: String {
        isDe ? "Karten-Stil" : "Map Style"
    }

    static var settingsStandard:  String { isDe ? "Standard" : "Standard" }
    static var settingsSatellite: String { isDe ? "Satellit"  : "Satellite" }
    static var settingsHybrid:    String { "Hybrid" }

    static var settingsAppInfo: String { isDe ? "App Info" : "App Info" }

    static var settingsVersion:   String { isDe ? "Version"    : "Version"   }
    static var settingsDeveloper: String { isDe ? "Entwickler" : "Developer" }
    static var settingsWebsite:   String { "Website" }

    static var settingsLegal: String {
        isDe ? "Rechtliches" : "Legal"
    }

    static var settingsImprint: String {
        isDe ? "Impressum" : "Imprint"
    }

    static var settingsPrivacy: String {
        isDe ? "Datenschutzerklärung" : "Privacy Policy"
    }

    static var settingsTerms: String {
        isDe ? "Nutzungsbedingungen" : "Terms of Use"
    }

    static var settingsFeedback: String {
        isDe ? "Feedback senden" : "Send Feedback"
    }

    static var settingsData: String {
        isDe ? "Daten" : "Data"
    }

    static var settingsResetOnboarding: String {
        isDe ? "Onboarding zurücksetzen" : "Reset Onboarding"
    }

    static var settingsLocation: String {
        isDe ? "Standort" : "Location"
    }

    static var settingsHome: String {
        isDe ? "Zuhause" : "Home"
    }

    static var settingsNoHome: String {
        isDe ? "Kein Zuhause gesetzt" : "No home location set"
    }

    static var settingsChange: String {
        isDe ? "Ändern" : "Change"
    }

    static var settingsAddHome: String {
        isDe ? "Zuhause hinzufügen" : "Add home location"
    }

    // MARK: Location Permission

    static var enableLocation: String {
        isDe ? "Standort in Einstellungen aktivieren" : "Enable location in Settings"
    }

    static var settingsGPS: String {
        isDe ? "GPS Standort" : "GPS Location"
    }

    static var settingsGPSActive: String {
        isDe ? "Aktiv" : "Active"
    }

    static var settingsGPSDenied: String {
        isDe ? "Verweigert" : "Denied"
    }

    static var settingsEnableGPS: String {
        isDe ? "Standort aktivieren" : "Enable Location"
    }

    // MARK: Home Location Sheet

    static var homeTitle: String {
        isDe ? "Wo ist dein Zuhause?" : "Where is your home?"
    }

    static var homeSubtitle: String {
        isDe
            ? "Mit einem Zuhause kannst du Tagebucheinträge noch schneller erfassen."
            : "With a home location, journal entries can be captured even faster."
    }

    static var homeSearchPlaceholder: String {
        isDe ? "Stadt oder Adresse suchen..." : "Search city or address..."
    }

    static var homeSkip: String {
        isDe ? "Kein Zuhause eingeben" : "Skip for now"
    }

    // MARK: Journal / Tagebuch

    static var journalHome: String {
        isDe ? "Tagebuch -\nZuhause" : "Journal -\nHome"
    }

    static var journalOnTheRoad: String {
        isDe ? "Tagebuch -\nUnterwegs" : "Journal -\nOn the Road"
    }

    static var journalSectionTitle: String {
        isDe ? "Tagebuch" : "Journal"
    }

    static var journalSectionSubtitle: String {
        isDe ? "Was bewegt dich heute?" : "What moves you today?"
    }
}
