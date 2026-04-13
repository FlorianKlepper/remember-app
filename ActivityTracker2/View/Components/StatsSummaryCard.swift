// StatsSummaryCard.swift
// ActivityTracker2 — Remember
// Kompakte Statistik-Karte mit 3 Kennzahlen

import SwiftUI

// MARK: - StatsSummaryCard

/// Zeigt drei Kennzahlen nebeneinander mit Trennlinien.
/// Verwendung: oben auf dem Stats-Screen als schneller Überblick.
struct StatsSummaryCard: View {

    // MARK: Parameter

    let totalCount: Int
    let thisWeek: Int
    let topCategoryName: String?
    let topCategoryIcon: String?

    // MARK: Body

    var body: some View {
        HStack(spacing: 0) {
            StatItemView(
                value: "\(totalCount)",
                labelKey: "stats.total_activities",
                systemImage: nil
            )

            Divider()
                .frame(height: 40)

            StatItemView(
                value: "\(thisWeek)",
                labelKey: "stats.this_week",
                systemImage: nil
            )

            Divider()
                .frame(height: 40)

            StatItemView(
                value: topCategoryName ?? "–",
                labelKey: "stats.top_category",
                systemImage: topCategoryIcon
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - StatItemView (privat)

/// Einzelne Statistik-Zelle: optionales Icon, Wert, Label.
private struct StatItemView: View {

    let value: String
    let labelKey: LocalizedStringKey
    var systemImage: String?

    var body: some View {
        VStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(labelKey)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Stats Summary Card") {
    VStack(spacing: 20) {
        StatsSummaryCard(
            totalCount: 42,
            thisWeek: 5,
            topCategoryName: "Wandern",
            topCategoryIcon: "figure.hiking"
        )
        StatsSummaryCard(
            totalCount: 0,
            thisWeek: 0,
            topCategoryName: nil,
            topCategoryIcon: nil
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
