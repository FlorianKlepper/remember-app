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
    var highlightedActivityId: UUID? = nil

    // MARK: Init

    init() {}
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
            span: MKCoordinateSpan(
                latitudeDelta: AppConstants.defaultMapSpan,
                longitudeDelta: AppConstants.defaultMapSpan
            )
        )

        withAnimation(.easeInOut(duration: 0.6)) {
            region = MKCoordinateRegion(
                center: targetCenter,
                span: MKCoordinateSpan(
                    latitudeDelta: AppConstants.defaultMapSpan,
                    longitudeDelta: AppConstants.defaultMapSpan
                )
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

        // Erste Activity an diesem Pin hervorheben (Kategorie-Filter respektieren)
        let atPin = displayedActivities.filter { $0.location?.id == location.id }
        highlightedActivityId = atPin.first?.id

        let targetCenter = adjustedCenter(for: location.coordinate, span: defaultSpan)
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: targetCenter,
                span: defaultSpan
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
            let targetCenter = adjustedCenter(for: location.coordinate, span: region.span)
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: targetCenter,
                    span: region.span
                )
            }
        }
    }

    // MARK: Private

    private var defaultSpan: MKCoordinateSpan {
        MKCoordinateSpan(
            latitudeDelta: AppConstants.defaultMapSpan,
            longitudeDelta: AppConstants.defaultMapSpan
        )
    }

    /// Verschiebt den Kartenmittelpunkt nach Süden, damit der Pin optisch
    /// im oberen Drittel der sichtbaren Map erscheint (nicht hinter dem Bottom Sheet).
    /// Offset: 18 % der latitudeDelta nach Süden.
    func adjustedCenter(
        for coordinate: CLLocationCoordinate2D,
        span: MKCoordinateSpan
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude:  coordinate.latitude  - span.latitudeDelta  * 0.18,
            longitude: coordinate.longitude
        )
    }
}
