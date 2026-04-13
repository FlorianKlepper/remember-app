// PlusBadge.swift
// ActivityTracker2 — Remember
// Kleines "PLUS"-Badge für Plus-Kategorien und Feature-Gates

import SwiftUI

// MARK: - PlusBadge

/// Kompaktes Badge das Plus-exklusive Inhalte kennzeichnet.
/// Wird als Overlay auf Plus-Kategorien in der Kategorie-Auswahl gezeigt.
struct PlusBadge: View {

    // MARK: Body

    var body: some View {
        Label("PLUS", systemImage: "star.fill")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color(hex: "#B45309"))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color(hex: "#FEF3C7"), in: Capsule())
    }
}

// MARK: - Preview

#Preview("Plus Badge") {
    VStack(spacing: 24) {
        // Badge alleine
        PlusBadge()

        // Badge als Overlay auf CategoryIconView
        CategoryIconView(categoryId: "climbing", size: 44)
            .overlay(alignment: .topTrailing) {
                PlusBadge()
                    .offset(x: 4, y: -4)
            }

        // Badge auf gedimmtem Icon (Free-User-Darstellung)
        CategoryIconView(categoryId: "yoga", size: 44)
            .opacity(0.5)
            .overlay(alignment: .topTrailing) {
                PlusBadge()
                    .offset(x: 4, y: -4)
            }
    }
    .padding(32)
    .background(Color(.systemBackground))
}
