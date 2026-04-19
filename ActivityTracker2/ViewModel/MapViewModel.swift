// MapViewModel.swift
// ActivityTracker2 — Remember
// Map-State, Pin-Tap-Logik und Liste-Synchronisation

import Foundation
import MapKit
import CoreLocation
import SwiftUI

// MARK: - MapViewModel

/// Verwaltet den State der Map und des Bottom Sheets.
///
/// Kernkonzept:
/// - `displayedActivities` ist IMMER die vollständige gefilterte Liste (Kategorie oder alle).
/// - `highlightedActivityId` zeigt welche Zeile hervorgehoben und auf der Map zentriert ist.
/// - Pin-Tap ändert nur das Highlight — die Liste bleibt komplett.
@Observable
@MainActor
final class MapViewModel {

    // MARK: Properties

    /// Sichtbarer Kartenausschnitt. Default: München Stadtmitte.
    var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: AppConstants.defaultLatitude,
            longitude: AppConstants.defaultLongitude
        ),
        span: MKCoordinateSpan(
            latitudeDelta: AppConstants.defaultMapSpan,
            longitudeDelta: AppConstants.defaultMapSpan
        )
    )

    /// Zuletzt angetippte Location (aktiver Pin) — steuert Pin-Highlight auf der Map.
    var selectedLocation: Location? = nil

    /// Vollständige gefilterte Activity-Liste für das Bottom Sheet.
    /// Beim Kategorie-Wechsel ersetzt, beim Pin-Tap unverändert.
    var displayedActivities: [Activity] = []

    /// ID der hervorgehobenen Activity — steuert Highlight-Zeile und Map-Zentrierung.
    /// Speichert beim Setzen den alten Wert in `previousHighlightedId`.
    var highlightedActivityId: UUID? = nil {
        didSet { previousHighlightedId = oldValue }
    }

    /// ID der zuletzt hervorgehobenen Activity — Ausgangspunkt für `animateToPin`.
    var previousHighlightedId: Activity.ID? = nil

    /// Aktueller Sheet-Detent — steuert Offset-Logik in `adjustedCenter`.
    /// 0.15 = klein, 0.5 = mittel, 1.0 = gross.
    var currentSheetDetent: Double = 0.15

    /// `true` nachdem die erste GPS-Koordinate empfangen und die Karte zentriert wurde.
    /// Verhindert wiederholtes Zentrieren bei jedem Location-Update.
    var hasInitialLocation: Bool = false

    // MARK: Private

    private let analytics: AnalyticsManager

    // MARK: Init

    /// - Parameter analytics: Für Map-Event-Tracking.
    init(analytics: AnalyticsManager) {
        self.analytics = analytics
    }
}

// MARK: - Pin-Logik

extension MapViewModel {

    /// Ermittelt die dominante Kategorie einer Location anhand der häufigsten Kategorie.
    /// - Parameters:
    ///   - location: Die Location deren dominante Kategorie ermittelt werden soll.
    ///   - activities: Alle verfügbaren Activities (gefiltert oder ungefiltert).
    /// - Returns: `categoryId` der häufigsten Kategorie, oder `nil` wenn keine Activity vorhanden.
    func dominantCategoryId(for location: Location, activities: [Activity]) -> String? {
        let locationActivities = activities.filter { $0.location?.id == location.id }
        guard !locationActivities.isEmpty else { return nil }
        let grouped = Dictionary(grouping: locationActivities, by: { $0.categoryId })
        return grouped.max { $0.value.count < $1.value.count }?.key
    }
}

// MARK: - Interaktionen

extension MapViewModel {

    /// Reagiert auf einen Kategorie-Wechsel in der ChipBar.
    ///
    /// Befüllt `displayedActivities` mit der gefilterten Liste und
    /// zentriert die Map auf die neueste Activity der Auswahl.
    /// Bei `nil` werden alle Activities angezeigt und auf die neueste zentriert.
    ///
    /// - Parameters:
    ///   - categoryId: Gewählte Kategorie-ID oder `nil` für "Alle".
    ///   - allActivities: Alle Activities (ungefiltert).
    func onCategorySelected(categoryId: String?, allActivities: [Activity]) {
        if let categoryId {
            displayedActivities = allActivities
                .filter { $0.categoryId == categoryId }
                .sorted { $0.date > $1.date }
        } else {
            displayedActivities = allActivities.sorted { $0.date > $1.date }
        }
        centerOnNewest(activities: displayedActivities)
    }

    /// Zentriert die Map auf die neueste Activity in der übergebenen Liste.
    /// Setzt `highlightedActivityId` und `selectedLocation` auf die neueste Activity.
    /// - Parameter activities: Gefilterte oder vollständige Activity-Liste (bereits sortierbar).
    func centerOnNewest(activities: [Activity]) {
        guard let newest = activities.sorted(by: { $0.date > $1.date }).first,
              let location = newest.location
        else { return }

        let targetCenter = adjustedCenter(
            for: location.coordinate,
            span: region.span,
            sheetDetent: currentSheetDetent
        )

        withAnimation(.easeInOut(duration: 0.6)) {
            region = MKCoordinateRegion(
                center: targetCenter,
                span: region.span
            )
        }

        highlightedActivityId = newest.id
        selectedLocation = location
    }

    /// Reagiert auf einen Pin-Tap auf der Map.
    ///
    /// `displayedActivities` bleibt unverändert — nur das Highlight wechselt
    /// zur ersten Activity an diesem Pin. Die Map zentriert auf den Pin.
    ///
    /// - Parameters:
    ///   - location: Angetippte Location.
    ///   - allActivities: Alle Activities (ungefiltert).
    ///   - categoryId: Aktiver Kategorie-Filter oder `nil`.
    func onPinTapped(location: Location, allActivities: [Activity], categoryId: String?) {
        selectedLocation = location
        analytics.track(.mapPinTapped)

        // Erste Activity an diesem Pin hervorheben (Kategorie-Filter respektieren)
        let atPin = displayedActivities.filter { $0.location?.id == location.id }
        highlightedActivityId = atPin.first?.id

        let targetCenter = adjustedCenter(for: location.coordinate, span: region.span, sheetDetent: currentSheetDetent)
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: targetCenter,
                span: region.span
            )
        }
    }

    /// Reagiert auf einen Tap auf eine Zeile in der Liste.
    ///
    /// Aktualisiert `highlightedActivityId` und zentriert die Map auf den Pin der Activity.
    /// - Parameter activity: Angetippte Activity.
    func onActivityTapped(_ activity: Activity) {
        highlightedActivityId = activity.id
        selectedLocation = activity.location

        if let location = activity.location {
            let targetCenter = adjustedCenter(for: location.coordinate, span: region.span, sheetDetent: currentSheetDetent)
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: targetCenter,
                    span: region.span
                )
            }
        }
    }

    /// Flüssige 3-Phasen Transition zwischen zwei Pins: rauszoomen → rüberfahren → reinzoomen.
    ///
    /// - Phase 1 (0–0.35s): Rauszoomen auf 3× + Fahrt zur Mitte zwischen altem und neuem Pin.
    /// - Phase 2 (0.35–0.70s): Reinzoomen auf ursprünglichen Span, zentriert auf neuen Pin.
    ///
    /// - Parameters:
    ///   - currentLocation: Aktuell hervorgehobene Location (Startpunkt). `nil` = kein Offset.
    ///   - newLocation: Ziel-Location (neuer Pin).
    ///   - currentSpan: Span der Region vor der Transition — wird am Ende wiederhergestellt.
    func animateToPin(
        from currentLocation: Location?,
        to newLocation: Location,
        currentSpan: MKCoordinateSpan
    ) {
        let zoomedOutSpan = MKCoordinateSpan(
            latitudeDelta:  currentSpan.latitudeDelta  * 3.0,
            longitudeDelta: currentSpan.longitudeDelta * 3.0
        )

        let midCenter: CLLocationCoordinate2D
        if let current = currentLocation {
            midCenter = CLLocationCoordinate2D(
                latitude:  (current.coordinate.latitude  + newLocation.coordinate.latitude)  / 2,
                longitude: (current.coordinate.longitude + newLocation.coordinate.longitude) / 2
            )
        } else {
            midCenter = newLocation.coordinate
        }

        // Phase 1: Rauszoomen + zur Mitte fahren
        withAnimation(.easeIn(duration: 0.45)) {
            region = MKCoordinateRegion(
                center: adjustedCenter(for: midCenter, span: zoomedOutSpan, sheetDetent: currentSheetDetent),
                span: zoomedOutSpan
            )
        }

        // Phase 2: Reinzoomen auf neuen Pin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeOut(duration: 0.45)) {
                self.region = MKCoordinateRegion(
                    center: self.adjustedCenter(
                        for: newLocation.coordinate,
                        span: currentSpan,
                        sheetDetent: self.currentSheetDetent
                    ),
                    span: currentSpan
                )
            }
        }
    }

    // MARK: Private

    /// Verschiebt den Kartenmittelpunkt abhängig vom Sheet-Detent.
    ///
    /// - Sheet klein (≤ 0.15):  kein Offset — Pin in echter Bildschirmmitte.
    /// - Sheet mittel (≤ 0.45): 18 % Offset nach Süden — Pin im oberen Drittel.
    /// - Sheet gross (> 0.45):  kein Offset — Map wird von Sheet überdeckt.
    ///
    /// - Parameters:
    ///   - coordinate: Ziel-Koordinate (Pin-Position).
    ///   - span: Aktueller Kartenausschnitt.
    ///   - sheetDetent: Aktueller Sheet-Zustand (0.15 / 0.5 / 1.0). Default: 0.5.
    func adjustedCenter(
        for coordinate: CLLocationCoordinate2D,
        span: MKCoordinateSpan,
        sheetDetent: Double = 0.5
    ) -> CLLocationCoordinate2D {
        let offsetFactor: Double
        if sheetDetent <= 0.15 {
            offsetFactor = 0.0
        } else if sheetDetent <= 0.45 {
            offsetFactor = 0.18
        } else {
            offsetFactor = 0.0
        }
        return CLLocationCoordinate2D(
            latitude:  coordinate.latitude  - span.latitudeDelta  * offsetFactor,
            longitude: coordinate.longitude
        )
    }
}
