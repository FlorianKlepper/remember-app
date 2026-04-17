// StarRatingView.swift
// ActivityTracker2 — Remember
// Wiederverwendbare Sterne-Bewertung (editierbar + read-only)

import SwiftUI

// MARK: - StarRatingView

/// Sterne-Bewertung (0–3). Editierbar in Add/Edit-Screens, read-only im Detail-Screen.
/// Zeigt "Bewertung"-Label links, Sterne-Picker rechts.
struct StarRatingView: View {

    // MARK: Parameter

    @Binding var rating: Int
    var isEditable: Bool = true

    // MARK: Body

    var body: some View {
        HStack(spacing: 12) {

            Text(String(localized: "rating.label", defaultValue: "Bewertung"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 6) {

                // Reset-Button — nur im Edit-Modus
                if isEditable {
                    Button {
                        rating = 0
                    } label: {
                        Image(systemName: "star.slash")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                rating == 0 ? Color(hex: "#E8593C") : Color(.systemGray3)
                            )
                    }
                    .buttonStyle(.plain)

                    Divider().frame(height: 16)
                }

                // 1–3 Sterne
                ForEach(1...3, id: \.self) { star in
                    if isEditable {
                        Button {
                            rating = star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 18))
                                .foregroundStyle(
                                    star <= rating ? Color(hex: "#FFD700") : Color(.systemGray3)
                                )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                star <= rating ? Color(hex: "#FFD700") : Color(.systemGray5)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview("Star Rating View") {
    @Previewable @State var editableRating: Int = 2
    let readOnlyRating = 3

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
