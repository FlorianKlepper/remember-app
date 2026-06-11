// StarRatingView.swift
// ActivityTracker2 — Remember
// Wiederverwendbare Sterne-Bewertung (editierbar + read-only)

import SwiftUI

// MARK: - StarRatingView

/// Sterne-Bewertung (0–5). Editierbar in Add/Edit-Screens, read-only im Detail-Screen.
/// Zeigt "Bewertung"-Label links, Sterne-Picker rechts.
struct StarRatingView: View {

    // MARK: Parameter

    @Binding var rating: Int
    var isEditable: Bool = true

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(String(localized: "rating.label", defaultValue: "Rating"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        if isEditable { rating = star }
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                star <= rating ? Color(hex: "#FFD700") : Color(.systemGray4)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEditable)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Star Rating View") {
    @Previewable @State var editableRating: Int = 3
    let readOnlyRating = 5

    return VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Editierbar")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            StarRatingView(rating: $editableRating, isEditable: true)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Read-only")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            StarRatingView(
                rating: .constant(readOnlyRating),
                isEditable: false
            )
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Keine Bewertung (0)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            StarRatingView(rating: .constant(0), isEditable: false)
        }
    }
    .padding(.vertical, 24)
    .background(Color(.systemBackground))
}
