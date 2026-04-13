// MapViewModel.swift
// ActivityTracker2 — Remember
// Map-State, Pin-Tap-Logik und Scroll-Synchronisation

import Foundation
import MapKit
import CoreLocation

// MARK: - MapViewModel

/// Verwaltet den State der Map — sichtbaren Bereich, selektierten Pin
/// und die Synchronisation zwischen Map-Pins und Bottom-Sheet-Scroll-Position.
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

    /// Zuletzt angetippte Location (aktiver Pin). `nil` = kein Pin selektiert.
    var selectedLocation: Location? = nil

    /// Activities am aktuell selektierten Pin — für das Bottom Sheet.
    var activitiesAtPin: [Activity] = []

    /// Index der im Bottom Sheet aktiven Activity.
    var selectedActivityIndex: Int = 0

    // MARK: Init

    init() {}
}

// MARK: - Pin-Logik

extension MapViewModel {

    /// Ermittelt die dominante Kategorie einer Location anhand der häufigsten Kategorie.
    /// Wird für das Pin-Icon auf der Map verwendet.
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

    /// Verarbeitet einen Pin-Tap: setzt `selectedLocation` und befüllt `activitiesAtPin`.
    /// - Parameters:
    ///   - location: Angetippte Location.
    ///   - activities: Alle verfügbaren Activities — bereits gefiltert durch FilterViewModel.
    func handlePinTap(location: Location, activities: [Activity]) {
        selectedLocation = location
        activitiesAtPin = activities.filter { $0.location?.id == location.id }
        selectedActivityIndex = 0
    }
}

// MARK: - Scroll-Synchronisation

extension MapViewModel {

    /// Synchronisiert Map-Region mit der Scroll-Position im Bottom Sheet.
    /// Verschiebt die Map so, dass der Pin der Activity am gegebenen Index zentriert ist.
    /// - Parameter index: Index der aktiven Activity in `activitiesAtPin`.
    func syncMapToScroll(index: Int) {
        guard activitiesAtPin.indices.contains(index) else { return }
        selectedActivityIndex = index

        guard let location = activitiesAtPin[index].location else { return }

        // Region verschiebt sich zum neuen Mittelpunkt, Zoom-Level bleibt erhalten
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: region.span
        )
    }
}
