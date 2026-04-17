// ActivityRowView.swift
// ActivityTracker2 — Remember
// Listenzeile im ListScreen

import SwiftUI

// MARK: - ActivityRowView

/// Zeigt eine einzelne Activity als kompakte Listenzeile.
/// Kein Swipe-to-Delete — Swipe-Gesten wechseln die Kategorie (Filter-Navigation).
struct ActivityRowView: View {

    // MARK: Parameter

    let activity: Activity
    var onCategoryTap: (() -> Void)? = nil

    // MARK: Body

    var body: some View {
        HStack(spacing: 12) {

            // ── Datum links ──────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {
                Text(activity.dayString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(activity.monthString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            // ── Titel + Ort + Text mitte ─────────────────────────
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let city = activity.location?.city, !city.isBlank {
                    Text(city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer(minLength: 4)

            // ── Sterne + Icon nebeneinander ──────────────────────
            HStack(alignment: .center, spacing: 6) {

                // Sterne links vom Icon
                if activity.starRating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...activity.starRating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color(hex: "#FFD700"))
                        }
                    }
                }

                // Icon rechts (tippbar wenn Callback vorhanden)
                if let onCategoryTap {
                    Button {
                        onCategoryTap()
                        HapticManager.selectionChanged()
                    } label: {
                        CategoryIconView(categoryId: activity.categoryId, size: 36)
                    }
                    .buttonStyle(.plain)
                } else {
                    CategoryIconView(categoryId: activity.categoryId, size: 36)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview("Activity Rows") {
    List {
        ForEach(Activity.samples) { activity in
            ActivityRowView(activity: activity)
        }
    }
    .listStyle(.plain)
}
