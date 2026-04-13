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

    // MARK: Private

    private var cityText: String? {
        activity.location?.city ?? activity.location?.region
    }

    private var subtitleParts: String {
        var parts: [String] = [activity.formattedDate]
        if let city = cityText, !city.isBlank {
            parts.append(city)
        }
        return parts.joined(separator: " · ")
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: 12) {

            // ── Icon ────────────────────────────────────────────
            CategoryIconView(categoryId: activity.categoryId, size: 36)

            // ── Titel + Datum/Ort ────────────────────────────────
            VStack(alignment: .leading, spacing: 3) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitleParts)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ── Favorit-Stern ────────────────────────────────────
            if activity.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(Color(.systemYellow))
            }
        }
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
