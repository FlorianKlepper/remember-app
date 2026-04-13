// CategoryIconView.swift
// ActivityTracker2 — Remember
// Wiederverwendbares Kategorie-Icon für Listen und Karten (NICHT für Map-Pins)

import SwiftUI

// MARK: - CategoryIconView

/// Zeigt ein rundes Kategorie-Icon im Stil "Option B":
/// heller farbiger Hintergrund + kräftiges SF Symbol in Kategoriefarbe.
/// Fallback bei unbekannter Kategorie: grauer Kreis mit Fragezeichen.
struct CategoryIconView: View {

    // MARK: Parameter

    /// Kategorie-ID zur Auflösung aus `Category.mvpCategories` / `Category.plusCategories`.
    let categoryId: String

    /// Durchmesser des Kreises in Punkten. Default: 36.
    var size: CGFloat = 36

    // MARK: Private

    private var category: Category? {
        (Category.mvpCategories + Category.plusCategories)
            .first(where: { $0.id == categoryId })
    }

    // MARK: Body

    var body: some View {
        Group {
            if let category {
                let color = Color(hex: category.colorHex)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                    Image(systemName: category.iconName)
                        .font(.system(size: size * 0.45, weight: .medium))
                        .foregroundStyle(color)
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                    Image(systemName: "questionmark")
                        .font(.system(size: size * 0.45, weight: .medium))
                        .foregroundStyle(Color(.systemGray))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview("Kategorie-Icons") {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            ForEach(["hiking", "restaurant", "concert", "museum", "cycling", "journal"], id: \.self) { id in
                VStack(spacing: 6) {
                    CategoryIconView(categoryId: id, size: 44)
                    CategoryIconView(categoryId: id, size: 28)
                    CategoryIconView(categoryId: id, size: 16)
                }
            }
            // Fallback
            VStack(spacing: 6) {
                CategoryIconView(categoryId: "unknown_id", size: 44)
                CategoryIconView(categoryId: "unknown_id", size: 28)
                CategoryIconView(categoryId: "unknown_id", size: 16)
            }
        }
        .padding()
    }
}
