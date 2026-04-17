// FloatingPlusButton.swift
// ActivityTracker2 — Remember
// Floating Action Button für den Add-Activity-Flow

import SwiftUI

// MARK: - FloatingPlusButton

/// Runder Floating Action Button (52×52 pt) mit echtem Floating-Effekt:
/// mehrschichtiger Schatten, weißer Glanz oben und Press-Animation.
struct FloatingPlusButton: View {

    // MARK: Parameter

    let action: () -> Void
    /// Hintergrundfarbe des Buttons. Default: systemGray2.
    /// Wird auf die aktive Kategorie-Farbe gesetzt wenn ein Filter aktiv ist.
    var color: Color = Color(.systemGray2)

    // MARK: Gesture State

    @GestureState private var isPressed = false

    // MARK: Body

    var body: some View {
        Button(action: action) {
            ZStack {
                // ── Äußerer weicher Shadow-Ring ──────────────────
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 62, height: 62)
                    .blur(radius: 8)
                    .offset(y: 4)

                // ── Haupt-Kreis ──────────────────────────────────
                Circle()
                    .fill(color)
                    .frame(width: 52, height: 52)
                    .shadow(
                        color: color.opacity(0.5),
                        radius: 8,
                        x: 0,
                        y: 6
                    )
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 3,
                        x: 0,
                        y: 2
                    )

                // ── Weißer Glanz oben (3D-Floating-Eindruck) ────
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 52, height: 52)
                    .allowsHitTesting(false)

                // ── Plus-Icon ────────────────────────────────────
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.90 : 1.0)
        .animation(
            .spring(response: 0.2, dampingFraction: 0.5),
            value: isPressed
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
        )
    }
}

// MARK: - Preview

#Preview("Floating Plus Button") {
    HStack(spacing: 32) {
        VStack(spacing: 8) {
            Text("Default")
                .font(.caption2)
                .foregroundStyle(.secondary)
            FloatingPlusButton(action: {})
        }
        VStack(spacing: 8) {
            Text("Kategorie-Farbe")
                .font(.caption2)
                .foregroundStyle(.secondary)
            FloatingPlusButton(action: {}, color: Color(hex: "#E8593C"))
        }
    }
    .padding(40)
    .background(Color(.systemGray5))
}
