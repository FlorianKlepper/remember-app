// PreReviewSheet.swift
// ActivityTracker2 — Remember
// Pre-Prompt Sheet vor dem nativen App-Store-Review-Dialog

import SwiftUI

// MARK: - PreReviewSheet

/// Zeigt einen freundlichen Pre-Prompt bevor der native iOS-Review-Dialog erscheint.
/// Gibt dem User die Wahl: Review, Feedback-Mail oder später.
struct PreReviewSheet: View {

    // MARK: Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {

            // ── Herz-Icon ────────────────────────────────────────────
            Image(systemName: "heart.fill")
                .font(.system(size: 56))
                .foregroundStyle(.pink)
                .padding(.top, 36)
                .padding(.bottom, 20)

            // ── Headline ──────────────────────────────────────────────
            Text(String(localized: "review.sheet.title",
                        defaultValue: "Enjoying Remember?"))
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // ── Untertitel ────────────────────────────────────────────
            Text(String(localized: "review.sheet.subtitle",
                        defaultValue: "Your feedback helps me improve the app. I'm a solo developer from Munich. 🇩🇪"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 10)
                .padding(.bottom, 32)

            // ── Buttons ───────────────────────────────────────────────
            VStack(spacing: 12) {

                // Primary: Review
                Button {
                    dismiss()
                    // Kurzer Delay damit Sheet geschlossen ist bevor iOS-Dialog erscheint
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        ReviewManager.shared.triggerSystemReview()
                    }
                } label: {
                    Text(String(localized: "review.sheet.cta.love",
                                defaultValue: "I love it! ❤️"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "#E8593C"))
                        )
                }

                // Secondary: Feedback-Mail
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        ReviewManager.shared.openFeedbackMail()
                    }
                } label: {
                    Text(String(localized: "review.sheet.cta.improve",
                                defaultValue: "Could be better…"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray5))
                        )
                }

                // Tertiary: Später
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "review.sheet.cta.later",
                                defaultValue: "Later"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 16)
        }
        .presentationDetents([.height(440)])
        .presentationCornerRadius(28)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

#Preview("Pre Review Sheet") {
    Text("Stats Screen")
        .sheet(isPresented: .constant(true)) {
            PreReviewSheet()
        }
}
