// WelcomeOverlayView.swift
// ActivityTracker2 — Remember
// Einmaliger Willkommens-Overlay nach Onboarding + erster App-Öffnung

import SwiftUI

// MARK: - WelcomeOverlayView

/// Einmaliger Willkommens-Overlay — erscheint nur wenn noch keine Aktivitäten vorhanden sind
/// und `hasSeenWelcome` noch nicht in UserDefaults gesetzt wurde.
/// Schreibt `hasSeenWelcome = true` beim Schließen — erscheint danach nie wieder.
struct WelcomeOverlayView: View {

    @Binding var isShowing: Bool

    // MARK: Body

    var body: some View {
        ZStack {
            // ── Abgedunkelter Hintergrund ─────────────────────────
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { }   // verhindert tap-through auf Karte

            // ── Card ──────────────────────────────────────────────
            VStack(spacing: 0) {

                // ── Screenshot ────────────────────────────────────
                Image("welcome_preview")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        maxWidth:  UIScreen.main.bounds.width  * 0.85,
                        maxHeight: UIScreen.main.bounds.height * 0.48
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, 20)

                // ── Titel + Text ──────────────────────────────────
                VStack(spacing: 0) {
                    Text(String(localized: "welcome.title",
                                defaultValue: "Hier entsteht deine\npersönliche Weltkarte."))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)

                    Text(String(localized: "welcome.body",
                                defaultValue: "Fang mit deinem ersten\nErlebnis an."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)

                // ── CTA Button ────────────────────────────────────
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Los geht's!")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#E8593C"))
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
        }
        .transition(.opacity)
    }
}

// MARK: - Preview

#Preview("Welcome Overlay") {
    @Previewable @State var isShowing = true

    ZStack {
        Color(.systemGray5).ignoresSafeArea()
        if isShowing {
            WelcomeOverlayView(isShowing: $isShowing)
        }
    }
}
