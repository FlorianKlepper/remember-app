// PlusScreen.swift
// ActivityTracker2 — Remember
// Paywall und Plus-Mitglieder-Ansicht

import SwiftUI
import StoreKit

// MARK: - PlusScreen

/// Zeigt Free-Usern die Paywall (Layout A) und Plus-Usern eine Danke-Ansicht (Layout B).
struct PlusScreen: View {

    // MARK: Environment

    @Environment(PlusViewModel.self)      private var plusVM
    @Environment(UserSettings.self)       private var userSettings
    @Environment(StoreKitManager.self)    private var storeKitManager
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(\.openURL)               private var openURL

    // MARK: Private

    private let brandColor = Color(hex: "#E8593C")

    // MARK: Body

    var body: some View {
        NavigationStack {
            Group {
                if userSettings.subscriptionStatus.isPremium {
                    plusMemberView
                } else {
                    paywallView
                }
            }
            .navigationTitle("plus.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await plusVM.loadProducts(from: storeKitManager)
            }
            analyticsManager.track(.paywallViewed(source: "tab"))
        }
    }

    // MARK: Layout A — Paywall (Free User)

    private var paywallView: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Hero ───────────────────────────────────────────
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(brandColor)

                    Text("plus.hero.title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("plus.hero.subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 24)

                // ── Vorteile ───────────────────────────────────────
                VStack(spacing: 16) {
                    benefitRow(
                        icon: "infinity",
                        titleKey: "plus.benefit1.title",
                        descriptionKey: "plus.benefit1.description"
                    )
                    benefitRow(
                        icon: "square.grid.2x2",
                        titleKey: "plus.benefit2.title",
                        descriptionKey: "plus.benefit2.description"
                    )
                    benefitRow(
                        icon: "chart.bar.fill",
                        titleKey: "plus.benefit3.title",
                        descriptionKey: "plus.benefit3.description"
                    )
                }
                .padding(.horizontal, 24)

                // ── Preis & Kaufen ─────────────────────────────────
                VStack(spacing: 12) {
                    if let product = plusVM.plusProduct {
                        Text(product.displayPrice)
                            .font(.system(size: 36, weight: .bold))
                    } else {
                        Text("8,99 €")
                            .font(.system(size: 36, weight: .bold))
                    }

                    Text("plus.price.once")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    purchaseButton

                    restoreButton
                }

                // ── Fehler-Meldung ─────────────────────────────────
                if let error = plusVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // ── Website-Link ────────────────────────────────────
                Button {
                    openURL(AppConstants.websiteURL)
                } label: {
                    Text("plus.learn_more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .underline()
                }
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: Layout B — Plus-Mitglied

    private var plusMemberView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("plus.member.title")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("plus.member.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: Private Views

    private func benefitRow(
        icon: String,
        titleKey: LocalizedStringKey,
        descriptionKey: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(brandColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(titleKey)
                    .font(.headline)
                Text(descriptionKey)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var purchaseButton: some View {
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
                        ProgressView()
                            .tint(.white)
                        Text("plus.purchasing")
                    }
                } else {
                    Text("plus.cta.purchase")
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(plusVM.isPurchasing ? brandColor.opacity(0.6) : brandColor,
                        in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(plusVM.isPurchasing)
        .padding(.horizontal, 24)
    }

    private var restoreButton: some View {
        Button {
            Task {
                try? await plusVM.restorePurchases(
                    manager: storeKitManager,
                    settings: userSettings
                )
            }
        } label: {
            Text("plus.restore")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Plus Screen — Free") {
    let analytics = AnalyticsManager()
    let plusVM = PlusViewModel(analytics: analytics)
    let settings = UserSettings()
    let storeKit = StoreKitManager()

    return PlusScreen()
        .environment(plusVM)
        .environment(settings)
        .environment(storeKit)
        .environment(analytics)
}

#Preview("Plus Screen — Plus Member") {
    let analytics = AnalyticsManager()
    let plusVM = PlusViewModel(analytics: analytics)
    let settings = UserSettings()
    let storeKit = StoreKitManager()
    settings.subscriptionStatus = .plus

    return PlusScreen()
        .environment(plusVM)
        .environment(settings)
        .environment(storeKit)
        .environment(analytics)
}
