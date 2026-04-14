// FloatingPlusButton.swift
// ActivityTracker2 — Remember
// Floating Action Button für den Add-Activity-Flow

import SwiftUI

// MARK: - FloatingPlusButton

/// Runder Floating Action Button (52×52 pt) in elegantem Dunkelgrau.
/// Positionierung erfolgt durch den aufrufenden Container (ContentView).
struct FloatingPlusButton: View {

    // MARK: Parameter

    let action: () -> Void
    /// Hintergrundfarbe des Buttons. Default: systemGray2.
    /// Wird auf die aktive Kategorie-Farbe gesetzt wenn ein Filter aktiv ist.
    var color: Color = Color(.systemGray2)

    // MARK: Body

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                )
                .frame(width: 52, height: 52)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 6,
                    x: 0,
                    y: 3
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Floating Plus Button") {
    ZStack {
        Color(.systemGray6)
            .ignoresSafeArea()

        FloatingPlusButton(action: {})
    }
}
