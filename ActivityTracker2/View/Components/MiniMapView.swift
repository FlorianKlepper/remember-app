// MiniMapView.swift
// ActivityTracker2 — Remember
// Kleiner nicht-interaktiver Kartenausschnitt für ActivityDetailScreen

import SwiftUI
import MapKit
import CoreLocation

// MARK: - MiniMapView

/// Statische, nicht scrollbare Kartenvorschau für einen einzelnen Ort.
/// Zoom-Level: ~500 m Radius (span 0.005).
/// Wird im ActivityDetailScreen und EditActivityScreen eingesetzt.
struct MiniMapView: View {

    // MARK: Parameter

    let coordinate: CLLocationCoordinate2D

    // MARK: Private

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    // MARK: Body

    var body: some View {
        Map(initialPosition: .region(region)) {
            Marker("", coordinate: coordinate)
        }
        .disabled(true)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(height: 160)
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview("Mini Map View") {
    VStack(spacing: 16) {
        Text("München Marienplatz")
            .font(.caption)
            .foregroundStyle(.secondary)

        MiniMapView(
            coordinate: CLLocationCoordinate2D(
                latitude: AppConstants.defaultLatitude,
                longitude: AppConstants.defaultLongitude
            )
        )

        Text("Venedig")
            .font(.caption)
            .foregroundStyle(.secondary)

        MiniMapView(
            coordinate: CLLocationCoordinate2D(
                latitude: 45.4408,
                longitude: 12.3155
            )
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
