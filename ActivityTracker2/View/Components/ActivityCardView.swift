// ActivityCardView.swift
// ActivityTracker2 — Remember
// Karten-Komponente für das horizontale Scrollen im Bottom Sheet

import SwiftUI

// MARK: - ActivityCardView

/// Kompakte vertikale Karte für eine Activity im Bottom Sheet.
/// `isSelected: true` zeigt einen farbigen Rand in der Kategoriefarbe.
struct ActivityCardView: View {

    // MARK: Parameter

    let activity: Activity
    var isSelected: Bool = false

    // MARK: Private

    private var categoryColor: Color {
        let allCategories = Category.mvpCategories + Category.plusCategories
        guard let category = allCategories.first(where: { $0.id == activity.categoryId }) else {
            return .gray
        }
        return Color(hex: category.colorHex)
    }

    private var cityText: String? {
        activity.location?.city ?? activity.location?.region
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 8) {

            // ── Icon ─────────────────────────────────────────────
            CategoryIconView(categoryId: activity.categoryId, size: 44)

            // ── Titel ────────────────────────────────────────────
            Text(activity.displayTitle)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(.primary)

            // ── Datum ────────────────────────────────────────────
            Text(activity.formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)

            // ── Stadt ─────────────────────────────────────────────
            if let city = cityText, !city.isBlank {
                Text(city)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? categoryColor : .clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: AppConstants.animationStandard), value: isSelected)
    }
}

// MARK: - Preview

#Preview("Activity Cards") {
    HStack(spacing: 12) {
        ForEach(Array(Activity.samples.prefix(3).enumerated()), id: \.offset) { index, activity in
            ActivityCardView(activity: activity, isSelected: index == 0)
        }
    }
    .padding()
    .background(Color(.systemGray6))
}
