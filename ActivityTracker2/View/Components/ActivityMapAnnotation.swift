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
/// 3. Label-Pill mit Kategorienamen
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

    private var circleSize: CGFloat { isSelected ? 44 : 36 }
    private var iconSize: CGFloat  { isSelected ? 20 : 16 }

    private var categoryName: String {
        guard let category else { return "" }
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return code == "de" ? category.nameDe : category.nameEn
    }

    // MARK: Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {

                // ── Kreis mit Icon ──────────────────────────────
                ZStack {
                    Circle()
                        .fill(pinColor)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2.5)
                        )
                    Image(systemName: category?.iconName ?? "mappin")
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(width: circleSize, height: circleSize)
                .shadow(
                    color: isSelected ? pinColor.opacity(0.4) : .clear,
                    radius: isSelected ? 6 : 0
                )

                // ── Dreieck-Spitze ──────────────────────────────
                DownwardTriangle()
                    .fill(pinColor)
                    .frame(width: 12, height: 7)
                    .offset(y: -1) // leichter Überlapp mit Kreis

                // ── Label-Pill ──────────────────────────────────
                if !categoryName.isEmpty {
                    Text(categoryName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#1C1C1E"), in: Capsule())
                        .foregroundStyle(.white)
                        .padding(.top, 2)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: AppConstants.animationStandard), value: isSelected)
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
