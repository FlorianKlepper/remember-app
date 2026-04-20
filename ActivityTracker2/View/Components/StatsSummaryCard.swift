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
    let topCategoryId: String?
    let topCategoryName: String?

    // MARK: Body

    var body: some View {
        HStack(spacing: 0) {
            StatItemView(
                value: "\(totalCount)",
                labelKey: "stats.total_activities"
            )

            Divider()
                .frame(height: 40)

            StatItemView(
                value: "\(thisWeek)",
                labelKey: "stats.this_week"
            )

            Divider()
                .frame(height: 40)

            // ── Top Kategorie — gross + farbig ──────────────────
            VStack(spacing: 6) {
                if let id = topCategoryId {
                    CategoryIconView(categoryId: id, size: 44)
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }

                Text(topCategoryName ?? "–")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(LocalizedStringKey("stats.top_category"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 3,  x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - StatItemView (privat)

/// Einzelne Statistik-Zelle: Wert + Label.
private struct StatItemView: View {

    let value: String
    let labelKey: LocalizedStringKey

    var body: some View {
        VStack(spacing: 4) {
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
            topCategoryId: "hiking",
            topCategoryName: "Wandern"
        )
        StatsSummaryCard(
            totalCount: 0,
            thisWeek: 0,
            topCategoryId: nil,
            topCategoryName: nil
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
