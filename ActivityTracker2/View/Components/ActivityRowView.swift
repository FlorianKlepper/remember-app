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

    // MARK: Environment

    @Environment(FilterViewModel.self) private var filterVM
    @Environment(MapViewModel.self)    private var mapVM

    // MARK: Body

    var body: some View {
        HStack(spacing: 8) {

            // ── Datum links ──────────────────────────────────────
            VStack(alignment: .center, spacing: 0) {
                Text(activity.dayString)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(activity.monthString)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 34)

            // ── Titel + Text + Ort mitte ─────────────────────────
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                let poi  = activity.location?.locationName ?? ""
                let city = activity.location?.city ?? ""

                if !poi.isEmpty && !city.isEmpty {
                    Text("\(poi) · \(city)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if !poi.isEmpty {
                    Text(poi)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if !city.isEmpty {
                    Text(city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 4)

            // ── Sterne oben + Icon (+ Thumbnail) unten ───────────
            VStack(alignment: .trailing, spacing: 4) {

                if activity.starRating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...max(activity.starRating, 1), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(hex: "#FFD700"))
                        }
                    }
                } else {
                    Color.clear.frame(height: 10)
                }

                HStack(spacing: 6) {
                    CategoryIconView(categoryId: activity.categoryId, size: 34)
                        .onTapGesture {
                            filterVM.setFilter(categoryId: activity.categoryId)
                            mapVM.highlightedActivityId = activity.id
                            HapticManager.selectionChanged()
                        }

                    if let photoData = activity.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 34, height: 34)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .frame(width: activity.photoData != nil ? 80 : 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview("Activity Rows") {
    let analytics  = AnalyticsManager()
    let filterVM   = FilterViewModel(analytics: analytics)
    let mapVM      = MapViewModel(analytics: analytics)

    return List {
        ForEach(Activity.samples) { activity in
            ActivityRowView(activity: activity)
        }
    }
    .listStyle(.plain)
    .environment(filterVM)
    .environment(mapVM)
}
