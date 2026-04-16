// AppConstants.swift
// ActivityTracker2 — Remember
// Globale Konstanten der App (nicht instanziierbar)

import Foundation

// MARK: - AppConstants

/// Zentrale, nicht instanziierbare Sammlung aller app-weiten Konstanten.
/// Alle Werte sind statisch und unveränderlich.
enum AppConstants {

    // MARK: Monetarisierung

    /// Maximale Anzahl an Aktivitäten im Free-Plan.
    static let freeActivityLimit: Int = 100

    /// StoreKit-Produkt-ID für den Plus-Einmalkauf.
    static let plusProductId: String = "com.remember.app.plus"

    /// Öffentliche Website der App.
    static let websiteURL: URL = {
        guard let url = URL(string: "https://remember-app.de") else {
            fatalError("AppConstants.websiteURL: ungültige URL – bitte Literal prüfen")
        }
        return url
    }()

    // MARK: Karte & Ortserkennung

    /// Radius in Metern, innerhalb dem zwei Koordinaten zur selben Location zusammengefasst werden.
    static let locationGroupingRadius: Double = 100.0

    /// Standardmittelpunkt der Karte (München Stadtmitte) – Fallback wenn kein GPS.
    static let defaultLatitude: Double = 48.1351

    /// Standardmittelpunkt der Karte (München Stadtmitte) – Fallback wenn kein GPS.
    static let defaultLongitude: Double = 11.5820

    /// Standardzoom der Karte als MKCoordinateSpan-Delta.
    static let defaultMapSpan: Double = 0.12

    // MARK: Eingabelimits

    /// Maximale Zeichenanzahl für den Aktivitätstitel.
    static let maxTitleLength: Int = 80

    /// Maximale Zeichenanzahl für den Aktivitätstext (Freitext/Tagebucheintrag).
    static let maxTextLength: Int = 5000

    // MARK: UI & Animation

    /// Standarddauer für SwiftUI-Animationen in Sekunden.
    static let animationStandard: Double = 0.3

    /// Anzeigedauer von Toast-Meldungen in Sekunden.
    static let toastDuration: Double = 2.0

    /// Bottom Sheet – schmaler Streifen (immer sichtbar nach Pin-Tap).
    static let bottomSheetSmall: Double = 0.15

    /// Bottom Sheet – halbe Bildschirmhöhe (Standard-Detent).
    static let bottomSheetMedium: Double = 0.45
}

// MARK: - Notification Names

extension Notification.Name {
    /// ContentView → PermanentBottomSheet: Sheet auf small setzen (Tab-Tap).
    static let setSheetSmall = Notification.Name("setSheetSmall")
    /// AddActivityTextScreen → PermanentBottomSheet: Sheet auf medium setzen (nach Speichern).
    static let setSheetMedium = Notification.Name("setSheetMedium")
    /// ContentView → PermanentBottomSheet: Sheet auf large setzen (Tab-Tap).
    static let setSheetLarge = Notification.Name("setSheetLarge")
    /// PermanentBottomSheet → ContentView: User hat Sheet manuell auf large gezogen.
    static let userDraggedSheetLarge = Notification.Name("userDraggedSheetLarge")
    /// PermanentBottomSheet → ContentView: User hat Sheet manuell auf small/medium gezogen.
    static let userDraggedSheetSmall = Notification.Name("userDraggedSheetSmall")
    /// PermanentBottomSheet → ContentView: Sheet ist nach Drag-Ende auf large.
    static let sheetBecameLarge = Notification.Name("sheetBecameLarge")
    /// PermanentBottomSheet → ContentView: Sheet ist nach Drag-Ende auf small/medium.
    static let sheetBecameSmall = Notification.Name("sheetBecameSmall")
}
