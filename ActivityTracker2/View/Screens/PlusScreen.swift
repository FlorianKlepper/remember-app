// PlusScreen.swift
// ActivityTracker2 — Remember
// Paywall und Plus-Mitglieder-Ansicht

import SwiftUI
import StoreKit

// MARK: - PlusScreen

/// Zeigt Free-Usern die Paywall (kompaktes Non-Scroll-Layout)
/// und Plus-Usern eine Danke-Ansicht.
struct PlusScreen: View {

    // MARK: Input

    /// Auslöser der Paywall — wird an Analytics weitergegeben.
    /// Mögliche Werte: "plus_tab", "settings", "category_locked", "activity_limit".
    var source: String = "plus_tab"

    // MARK: Environment

    @Environment(PlusViewModel.self)      private var plusVM
    @Environment(UserSettings.self)       private var userSettings
    @Environment(StoreKitManager.self)    private var storeKitManager
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(\.dismiss)               private var dismiss

    // MARK: Body

    var body: some View {
        Group {
            if userSettings.subscriptionStatus.isPremium {
                plusMemberView
            } else {
                paywallView
            }
        }
        .onAppear {
            Task {
                await plusVM.loadProducts(from: storeKitManager)
            }
            analyticsManager.track(.paywallViewed(source: source))
        }
    }

    // MARK: Layout A — Paywall (Free User)

    private var paywallView: some View {
        VStack(spacing: 0) {



            // ── Header ────────────────────────────────────────────
            VStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: "#FFD700"))

                Text(L10n.plusTitle)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(L10n.plusSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)

            // ── Features — kompakt ────────────────────────────────
            VStack(spacing: 10) {
                plusRow(icon: "infinity",              text: L10n.plusFeatureUnlimited)
                plusRow(icon: "square.grid.3x3.fill", text: L10n.plusFeatureCategories)
                plusRow(icon: "lock.open.fill",        text: L10n.plusFeatureOnetime)
                plusRow(icon: "hand.raised.fill",      text: L10n.plusFeaturePrivacy)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)

            // ── Preis ─────────────────────────────────────────────
            Text(L10n.plusPrice)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(L10n.plusLaunchPrice)
                .font(.caption)
                .foregroundStyle(Color(hex: "#E8593C"))
                .padding(.top, 4)
                .padding(.bottom, 20)

            // ── Kauf Button ───────────────────────────────────────
            Button {
                Task {
                    await plusVM.purchasePlus(
                        manager: storeKitManager,
                        settings: userSettings
                    )
                }
            } label: {
                Group {
                    if plusVM.isPurchasing {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Wird verarbeitet…")
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color(hex: "#FFD700"))
                            Text(L10n.plusCta)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(plusVM.isPurchasing
                              ? Color(hex: "#E8593C").opacity(0.6)
                              : Color(hex: "#E8593C"))
                )
            }
            .disabled(plusVM.isPurchasing)
            .padding(.horizontal, 24)

            // ── Restore ───────────────────────────────────────────
            Button {
                Task {
                    try? await plusVM.restorePurchases(
                        manager: storeKitManager,
                        settings: userSettings
                    )
                }
            } label: {
                Text(L10n.plusRestore)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            // ── Fehler ────────────────────────────────────────────
            if let error = plusVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
            }

            Spacer()

            // ── Made in Munich ────────────────────────────────────
            Divider()
                .padding(.horizontal, 40)
                .padding(.vertical, 12)

            HStack(spacing: 8) {
                Text("🇩🇪")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.indieApp)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(L10n.madeIn)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 24)
        }
    }

    // MARK: Layout B — Plus-Mitglied

    private var plusMemberView: some View {
        VStack(spacing: 16) {

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text(String(localized: "plus.member.title",
                        defaultValue: "Du bist dabei!"))
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(String(localized: "plus.member.subtitle",
                        defaultValue: "Danke für deine Unterstützung.\nAlle Momente gehören dir."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: Feature Row

    private func plusRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: "#E8593C"))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "#E8593C").opacity(0.6))
        }
    }
}

// MARK: - Preview

#Preview("Plus Screen — Free") {
    let analytics = AnalyticsManager()
    let plusVM    = PlusViewModel(analytics: analytics)
    let settings  = UserSettings()
    let storeKit  = StoreKitManager()

    return PlusScreen()
        .environment(plusVM)
        .environment(settings)
        .environment(storeKit)
        .environment(analytics)
}

#Preview("Plus Screen — Plus Member") {
    let analytics = AnalyticsManager()
    let plusVM    = PlusViewModel(analytics: analytics)
    let settings  = UserSettings()
    let storeKit  = StoreKitManager()
    settings.subscriptionStatus = .plus

    return PlusScreen()
        .environment(plusVM)
        .environment(settings)
        .environment(storeKit)
        .environment(analytics)
}
