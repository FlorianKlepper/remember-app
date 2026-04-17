// ActivityMapAnnotation.swift
// ActivityTracker2 — Remember
// Custom Map-Pin für MapKit — kein SwiftData Import

import SwiftUI
import MapKit

// MARK: - ActivityMapAnnotation

/// Custom Kartennadel für Map-Pins.
/// Normal: weißer Kreis + farbiger Rand + farbiges Icon
/// Aktiv: weißer Kreis + goldener Rand + goldener Glow + farbiges Icon (größer)
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

    private var iconName: String {
        category?.iconName ?? "mappin"
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
                .fill(.white)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(pinColor, lineWidth: 2.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)

            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(pinColor)
        }
    }

    // MARK: Selected Pin

    private var selectedPin: some View {
        ZStack {
            // Äußerer Gold-Halo
            Circle()
                .fill(goldColor.opacity(0.20))
                .frame(width: 52, height: 52)

            // Weißer Kreis mit goldenem Rand
            Circle()
                .fill(.white)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle()
                        .strokeBorder(goldColor, lineWidth: 3.5)
                )
                .shadow(color: goldColor.opacity(0.5), radius: 6, x: 0, y: 0)

            // Icon in Kategorie-Farbe (größer)
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(pinColor)
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
        VStack(spacing: 8) {
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

        VStack(spacing: 8) {
            Text("Aktiv")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ActivityMapAnnotation(
                location: munich,
                dominantCategoryId: "hiking",
                isSelected: true,
                onTap: {}
            )
        }

        VStack(spacing: 8) {
            Text("Restaurant")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ActivityMapAnnotation(
                location: munich,
                dominantCategoryId: "restaurant",
                isSelected: false,
                onTap: {}
            )
        }
    }
    .padding(40)
    .background(Color(.systemGray5))
}
