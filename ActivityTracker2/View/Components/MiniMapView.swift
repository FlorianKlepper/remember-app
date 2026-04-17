// MiniMapView.swift
// ActivityTracker2 — Remember
// Kleiner nicht-interaktiver Kartenausschnitt mit eigenem Kategorie-Pin

import SwiftUI
import MapKit
import CoreLocation

// MARK: - MiniMapView

/// Statische, nicht scrollbare Kartenvorschau für einen einzelnen Ort.
/// Zoom-Level: ~500 m Radius (span 0.005).
/// Zeigt einen eigenen CategoryIcon-Pin statt dem Standard-Apple-Marker.
struct MiniMapView: View {

    // MARK: Parameter

    let coordinate: CLLocationCoordinate2D
    var categoryId: String = ""

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
            Annotation("", coordinate: coordinate) {
                MiniActivityPin(categoryId: categoryId)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .disabled(true)
        .allowsHitTesting(false)
    }
}

// MARK: - MapPinItem

private struct MapPinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - MiniActivityPin

/// Kleinere Version des Haupt-Map-Pins: weißer Kreis + farbiger Rand + Icon + Dreieck.
private struct MiniActivityPin: View {

    let categoryId: String

    private var category: Category? {
        (Category.mvpCategories + Category.plusCategories)
            .first { $0.id == categoryId }
    }

    private var pinColor: Color {
        Color(hex: category?.colorHex ?? "E8593C")
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(pinColor, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)

                Image(systemName: category?.iconName ?? "mappin.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(pinColor)
            }

            // Dreieck-Spitze
            Triangle()
                .fill(pinColor)
                .frame(width: 6, height: 4)
        }
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("Mini Map View") {
    VStack(spacing: 20) {
        Text("Wandern — München")
            .font(.caption)
            .foregroundStyle(.secondary)

        MiniMapView(
            coordinate: CLLocationCoordinate2D(
                latitude: AppConstants.defaultLatitude,
                longitude: AppConstants.defaultLongitude
            ),
            categoryId: "hiking"
        )
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))

        Text("Restaurant — Venedig")
            .font(.caption)
            .foregroundStyle(.secondary)

        MiniMapView(
            coordinate: CLLocationCoordinate2D(latitude: 45.4408, longitude: 12.3155),
            categoryId: "restaurant"
        )
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
    .background(Color(.systemBackground))
}
