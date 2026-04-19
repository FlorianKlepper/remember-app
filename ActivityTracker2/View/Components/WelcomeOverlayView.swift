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

                // ── Illustration ──────────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 340)

                    // Placeholder — später durch echten Screenshot ersetzen:
                    // Image("welcome_screenshot")
                    //     .resizable()
                    //     .aspectRatio(contentMode: .fit)
                    //     .frame(height: 340)
                    //     .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "#E8593C"))
                        Text(String(localized: "welcome.illustration.label",
                                    defaultValue: "Deine Erlebnisse\nauf der Karte"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                // ── Titel + Text ──────────────────────────────────
                VStack(spacing: 12) {
                    Text(String(localized: "welcome.title",
                                defaultValue: "Willkommen bei Remember!"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(String(localized: "welcome.body",
                                defaultValue: "Tippe auf das + um deine erste Aktivität zu erstellen und deine Reise mit Remember zu starten."))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // ── CTA Button ────────────────────────────────────
                Button {
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                        Text(String(localized: "welcome.cta",
                                    defaultValue: "Los geht's!"))
                            .font(.headline)
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
                .padding(.top, 24)
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
