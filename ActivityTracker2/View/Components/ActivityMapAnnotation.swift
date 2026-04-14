// ActivityMapAnnotation.swift
// ActivityTracker2 — Remember
// Custom Map-Pin für MapKit — kein SwiftData Import

import SwiftUI
import MapKit

// MARK: - ActivityMapAnnotation

/// Custom Kartennadel für Map-Pins.
/// Aufbau von oben nach unten:
/// 1. Gefüllter Kreis mit weißem Rand + SF Symbol (weiß)
/// 2. Dreieck (gleiche Farbe) als Spitze nach unten
struct ActivityMapAnnotation: View {

    // MARK: Parameter

    let location: Location
    let dominantCategoryId: String?
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: Private

    private var category: Category? {
        guard let id = dominantCategoryId else { return nil }
        return (Category.mvpCategories + Category.plusCategories)
            .first(where: { $0.id == id })
    }

    private var pinColor: Color {
        Color(hex: category?.colorHex ?? "#8E8E93")
    }

    private let goldColor = Color(hex: "#FFD700")

    // MARK: Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if isSelected {
                    selectedPin
                } else {
                    normalPin
                }

                // ── Dreieck-Spitze ──────────────────────────────
                DownwardTriangle()
                    .fill(isSelected ? goldColor : pinColor)
                    .frame(width: isSelected ? 9 : 8, height: isSelected ? 7 : 6)
                    .offset(y: -1)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }

    // MARK: Normal Pin

    private var normalPin: some View {
        ZStack {
            Circle()
                .fill(pinColor)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )
            Image(systemName: category?.iconName ?? "mappin")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: 28, height: 28)
    }

    // MARK: Selected Pin

    private var selectedPin: some View {
        ZStack {
            // Dezenter goldener Halo
            Circle()
                .fill(goldColor.opacity(0.20))
                .frame(width: 46, height: 46)

            // Haupt-Kreis mit goldenem Rahmen
            Circle()
                .fill(pinColor)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(goldColor, lineWidth: 2.5)
                )
                .shadow(
                    color: goldColor.opacity(0.5),
                    radius: 5,
                    x: 0,
                    y: 0
                )

            Image(systemName: category?.iconName ?? "mappin")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - DownwardTriangle

/// Dreieck mit Spitze nach unten.
private struct DownwardTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview("Map Pins") {
    let munich = Location(
        latitude: 48.1351, longitude: 11.5820,
        city: "München", region: "Bayern", country: "Deutschland"
    )

    HStack(spacing: 32) {
        VStack {
            Text("Normal")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ActivityMapAnnotation(
                location: munich,
                dominantCategoryId: "hiking",
                isSelected: false,
                onTap: {}
            )
        }

        VStack {
            Text("Ausgewählt")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ActivityMapAnnotation(
                location: munich,
                dominantCategoryId: "restaurant",
                isSelected: true,
                onTap: {}
            )
        }

        VStack {
            Text("Kein Typ")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ActivityMapAnnotation(
                location: munich,
                dominantCategoryId: nil,
                isSelected: false,
                onTap: {}
            )
        }
    }
    .padding(40)
    .background(Color(.systemGray6))
}
