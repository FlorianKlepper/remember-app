// LimitReachedSheet.swift
// ActivityTracker2 — Remember
// Sheet wenn Free-Limit (100 Aktivitäten) erreicht ist

import SwiftUI

// MARK: - LimitReachedSheet

/// Erscheint wenn ein Free-User versucht, eine weitere Aktivität zu erstellen
/// nachdem das Limit von 100 erreicht wurde.
struct LimitReachedSheet: View {

    // MARK: Parameter

    @Binding var isShowing: Bool

    // MARK: Environment

    @Environment(UserSettings.self)    private var userSettings
    @Environment(StoreKitManager.self) private var storeKitManager

    // MARK: State

    @State private var isPurchasing = false

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {

            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFD700").opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: "#FFD700"))
            }
            .padding(.bottom, 20)

            // Titel
            Text(L10n.limitTitle)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            // Beschreibung
            Text(L10n.limitSubtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

            // Feature-Liste
            VStack(spacing: 12) {
                plusFeatureRow(icon: "infinity",              text: L10n.limitFeatureUnlimited)
                plusFeatureRow(icon: "square.grid.3x3.fill", text: L10n.limitFeatureCategories)
                plusFeatureRow(icon: "crown.fill",            text: L10n.limitFeatureOnetime)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // Kauf-Button
            Button {
                Task {
                    guard let product = storeKitManager.plusProduct else { return }
                    isPurchasing = true
                    let success = (try? await storeKitManager.purchase(product, settings: userSettings)) ?? false
                    isPurchasing = false
                    if success { isShowing = false }
                }
            } label: {
                HStack(spacing: 8) {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color(hex: "#FFD700"))
                        Text(L10n.limitCta)
                            .fontWeight(.semibold)
                    }
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
            .disabled(isPurchasing)

            // Abbrechen
            Button {
                isShowing = false
            } label: {
                Text(L10n.limitLater)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onAppear {
            #if DEBUG
            print("Locale: \(Locale.current.language.languageCode?.identifier ?? "unknown")")
            print("limit.title: \(L10n.limitTitle)")
            #endif
        }
    }

    // MARK: Helper

    private func plusFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "#E8593C"))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Limit Reached Sheet") {
    @Previewable @State var isShowing = true
    let settings = UserSettings()
    let storeKit = StoreKitManager()

    return Color.clear.sheet(isPresented: $isShowing) {
        LimitReachedSheet(isShowing: $isShowing)
            .environment(settings)
            .environment(storeKit)
    }
}
