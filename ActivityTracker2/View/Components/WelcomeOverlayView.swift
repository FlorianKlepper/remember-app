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

    // MARK: Image Name (sprachabhängig)

    private var welcomeImage: String { L10n.isDe ? "welcome_preview" : "welcome_preview_en" }

    // MARK: Body

    var body: some View {
        ZStack {
            // ── Abgedunkelter Hintergrund ─────────────────────────
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { }   // verhindert tap-through auf Karte

            // ── Card ──────────────────────────────────────────────
            VStack(spacing: 28) {

                // ── Handle ────────────────────────────────────────
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // ── Screenshot ────────────────────────────────────
                Image(welcomeImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.45)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, 36)

                // ── Titel + Text ──────────────────────────────────
                VStack(spacing: 8) {
                    Text(String(localized: "welcome.title",
                                defaultValue: "Your personal\nworld map starts here."))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(String(localized: "welcome.body",
                                defaultValue: "Start with your first\nexperience."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                // ── CTA Button ────────────────────────────────────
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text(String(localized: "welcome.cta",
                                    defaultValue: "Let's go!"))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#E8593C"))
                    )
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 24)
            }
            .padding(.bottom, 32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 16)
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
