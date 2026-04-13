// FloatingPlusButton.swift
// ActivityTracker2 — Remember
// Floating Action Button für den Add-Activity-Flow

import SwiftUI

// MARK: - FloatingPlusButton

/// Runder Floating Action Button (56×56 pt) in der Markenfarbe Coral.
/// Positioniert sich selbst via `frame(maxWidth: .infinity, maxHeight: .infinity)`
/// in der unteren rechten Ecke des übergeordneten Containers.
struct FloatingPlusButton: View {

    // MARK: Parameter

    let action: () -> Void

    // MARK: Body

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: "#E8593C"), in: Circle())
                        .shadow(
                            color: Color(hex: "#E8593C").opacity(0.35),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
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
