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
            .frame(width: 36)

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

                let poi          = activity.location?.locationName ?? ""
                let city         = activity.location?.city ?? ""
                let locationText = poi.isEmpty ? city : city.isEmpty ? poi : "\(poi) · \(city)"

                if !locationText.isEmpty {
                    Text(locationText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ── Sterne oben + Foto + Icon unten ──────────────────
            VStack(alignment: .trailing, spacing: 2) {

                if activity.starRating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...max(activity.starRating, 1), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color(hex: "#FFD700"))
                        }
                    }
                } else {
                    Color.clear.frame(height: 9)
                }

                HStack(spacing: 6) {
                    if let photoData = activity.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    CategoryIconView(categoryId: activity.categoryId, size: 38)
                        .onTapGesture {
                            filterVM.setFilter(categoryId: activity.categoryId)
                            mapVM.highlightedActivityId = activity.id
                            HapticManager.selectionChanged()
                        }
                }
            }
            .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
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
