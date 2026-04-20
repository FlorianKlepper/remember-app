// SmoothMapView.swift
// ActivityTracker2 — Remember
// UIViewRepresentable MKMapView für smooth native Kamera-Animationen

import SwiftUI
import MapKit

// MARK: - SmoothMapView

/// UIViewRepresentable-Wrapper um MKMapView.
/// SwiftUI Map() ignoriert withAnimation — diese Implementierung nutzt
/// native UIKit spring-Animationen via UIView.animate + setRegion(animated:).
struct SmoothMapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    var annotations: [ActivityAnnotation]
    var mapStyle: String
    var onRegionChange: (MKCoordinateRegion) -> Void
    var onAnnotationTap: (ActivityAnnotation) -> Void

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.register(
            PinAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: PinAnnotationView.reuseId
        )
        applyMapType(to: mapView)
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        applyMapType(to: mapView)
        updateRegion(on: mapView)
        updateAnnotations(on: mapView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: Private Helpers

    private func applyMapType(to mapView: MKMapView) {
        let target: MKMapType
        switch mapStyle {
        case "satellite": target = .satellite
        case "hybrid":    target = .hybrid
        default:          target = .standard
        }
        if mapView.mapType != target { mapView.mapType = target }
    }

    /// Animiert die Region — weit entfernt (>0.005°) → Google-Style, nah → sanftes Gleiten.
    /// Threshold 0.0001° verhindert Feedback-Loop bei User-Drag.
    private func updateRegion(on mapView: MKMapView) {
        let current  = mapView.region
        let latDiff  = abs(current.center.latitude  - region.center.latitude)
        let lonDiff  = abs(current.center.longitude - region.center.longitude)
        let spanDiff = abs(current.span.latitudeDelta - region.span.latitudeDelta)

        guard latDiff > 0.0001 || lonDiff > 0.0001 || spanDiff > 0.0001 else { return }

        if latDiff > 0.005 || lonDiff > 0.005 {
            // Weit entfernt → Zoom Out → rüberfahren → Zoom In (Google Maps Style)
            animateGoogleStyle(mapView: mapView, to: region)
        } else {
            // Nah → sanftes Gleiten ohne Zoom-Änderung
            UIView.animate(
                withDuration: 0.9,
                delay: 0,
                usingSpringWithDamping: 0.88,
                initialSpringVelocity: 0.2,
                options: .curveEaseInOut
            ) {
                mapView.setRegion(self.region, animated: true)
            }
        }
    }

    /// Zweiphasige Übergangs-Animation: Zoom Out zur Mitte → Zoom In auf Ziel.
    /// Wird übersprungen wenn der aktuelle Span bereits sehr groß ist (>30°).
    private func animateGoogleStyle(mapView: MKMapView, to newRegion: MKCoordinateRegion) {
        let currentRegion = mapView.region

        // Bei großem Span kein Zoom-Out — würde ungültige Region erzeugen
        guard currentRegion.span.latitudeDelta < 30 else {
            UIView.animate(
                withDuration: 0.9,
                delay: 0,
                usingSpringWithDamping: 0.88,
                initialSpringVelocity: 0.2,
                options: .curveEaseInOut
            ) {
                mapView.setRegion(newRegion, animated: true)
            }
            return
        }

        let midCenter = CLLocationCoordinate2D(
            latitude:  (currentRegion.center.latitude  + newRegion.center.latitude)  / 2,
            longitude: (currentRegion.center.longitude + newRegion.center.longitude) / 2
        )
        // Span auf gültige MKMapView-Grenzen clampen (max 85° / 170°)
        let zoomedOutSpan = MKCoordinateSpan(
            latitudeDelta:  min(max(currentRegion.span.latitudeDelta,  newRegion.span.latitudeDelta)  * 2.5, 85.0),
            longitudeDelta: min(max(currentRegion.span.longitudeDelta, newRegion.span.longitudeDelta) * 2.5, 170.0)
        )

        // Phase 1: Rauszoomen zur Mitte
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2
        ) {
            mapView.setRegion(
                MKCoordinateRegion(center: midCenter, span: zoomedOutSpan),
                animated: true
            )
        } completion: { _ in
            // Phase 2: Reinzoomen auf Ziel
            UIView.animate(
                withDuration: 0.55,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.2
            ) {
                mapView.setRegion(newRegion, animated: true)
            }
        }
    }

    /// Diff-basiertes Annotation-Update: nur hinzufügen/entfernen/aktualisieren was nötig.
    private func updateAnnotations(on mapView: MKMapView) {
        let current    = mapView.annotations.compactMap { $0 as? ActivityAnnotation }
        let currentMap = Dictionary(uniqueKeysWithValues: current.map { ($0.id, $0) })
        let newMap     = Dictionary(uniqueKeysWithValues: annotations.map { ($0.id, $0) })

        // Entfernen
        let toRemove = current.filter { newMap[$0.id] == nil }
        if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }

        // Hinzufügen
        let toAdd = annotations.filter { currentMap[$0.id] == nil }
        if !toAdd.isEmpty { mapView.addAnnotations(toAdd) }

        // Selektion geändert → remove + re-add damit viewFor neu gerufen wird
        let selectionChanged = annotations.compactMap { ann -> ActivityAnnotation? in
            guard let existing = currentMap[ann.id],
                  existing.isSelected != ann.isSelected else { return nil }
            return ann
        }
        if !selectionChanged.isEmpty {
            let oldOnes = selectionChanged.compactMap { currentMap[$0.id] }
            mapView.removeAnnotations(oldOnes)
            mapView.addAnnotations(selectionChanged)
        }
    }
}

// MARK: - Coordinator

extension SmoothMapView {

    final class Coordinator: NSObject, MKMapViewDelegate {

        var parent: SmoothMapView

        init(_ parent: SmoothMapView) {
            self.parent = parent
        }

        /// User hat Karte gedragen — Region zurückmelden.
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.onRegionChange(mapView.region)
            }
        }

        /// Custom Pin-View mit ActivityMapAnnotation als SwiftUI-Content.
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? ActivityAnnotation else { return nil }
            guard let location = ann.activity.location else { return nil }

            guard let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: PinAnnotationView.reuseId,
                for: annotation
            ) as? PinAnnotationView else { return nil }

            view.setContent(
                ActivityMapAnnotation(
                    location: location,
                    dominantCategoryId: ann.activity.categoryId,
                    isSelected: ann.isSelected,
                    onTap: { [weak self] in
                        self?.parent.onAnnotationTap(ann)
                    }
                )
            )
            return view
        }
    }
}

// MARK: - PinAnnotationView

/// Wiederverwendbare MKAnnotationView mit eingebettetem SwiftUI-Content.
/// Hält den UIHostingController für effizientes Dequeuing.
private final class PinAnnotationView: MKAnnotationView {

    static let reuseId = "ActivityPin"
    private var hostingController: UIHostingController<AnyView>?

    /// Setzt den SwiftUI-Content. Erstellt den UIHostingController beim ersten Aufruf,
    /// aktualisiert nur den rootView bei Reuse.
    func setContent<V: View>(_ content: V) {
        if let existing = hostingController {
            existing.rootView = AnyView(content)
        } else {
            let hc = UIHostingController(rootView: AnyView(content))
            hc.view.backgroundColor = .clear
            hc.view.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
            addSubview(hc.view)
            frame = hc.view.frame
            centerOffset = CGPoint(x: 0, y: -30)
            hostingController = hc
        }
    }
}

// MARK: - ActivityAnnotation

/// MKAnnotation-Wrapper für eine Activity — ein Pin auf der Karte.
final class ActivityAnnotation: NSObject, MKAnnotation, Identifiable {

    let id: UUID
    let activity: Activity
    var isSelected: Bool

    var coordinate: CLLocationCoordinate2D {
        activity.location?.coordinate ?? CLLocationCoordinate2D()
    }

    /// - Parameters:
    ///   - activity: Die zugehörige Activity — `activity.location` liefert die Kartenposition.
    ///   - isSelected: `true` wenn dieser Pin aktuell hervorgehoben ist.
    init(activity: Activity, isSelected: Bool = false) {
        self.id = activity.id
        self.activity = activity
        self.isSelected = isSelected
    }
}
