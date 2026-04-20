// OnboardingScreen.swift
// ActivityTracker2 — Remember
// 3-seitiger Onboarding-Flow: App-Wert → Datenschutz → Standort-Berechtigung

import SwiftUI
import CoreLocation

// MARK: - OnboardingScreen

/// Vollbild-Onboarding mit `TabView(.page)` — 3 Screens.
/// Screen 0: App-Wert
/// Screen 1: Datenschutz-Versprechen
/// Screen 2: Standort-Berechtigung (iOS-Dialog vorher anzeigen)
struct OnboardingScreen: View {

    // MARK: Environment

    @Environment(OnboardingViewModel.self) private var onboardingVM
    @Environment(LocationManager.self)     private var locationManager
    @Environment(UserSettings.self)        private var userSettings
    @Environment(AnalyticsManager.self)    private var analyticsManager

    // MARK: State

    /// Steuert den LocationPermissionDeniedScreen (Sackgassen-Screen).
    @State private var showDeniedScreen = false

    // MARK: Body

    var body: some View {
        @Bindable var vm = onboardingVM

        TabView(selection: $vm.currentPage) {
            page1.tag(0)
            page2.tag(1)
            page3.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showDeniedScreen) {
            LocationPermissionDeniedScreen()
        }
    }

    // MARK: Page 1 — App-Wert

    private var page1: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "map.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color(hex: "#E8593C"))

            VStack(spacing: 10) {
                Text(String(localized: "onboarding.screen1.title",
                            defaultValue: "Dein Leben. Deine Karte."))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding.screen1.subtitle",
                            defaultValue: "Jeder Moment zählt."))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            nextButton { onboardingVM.nextPage() }
            skipButton
        }
        .padding(.bottom, 56)
    }

    // MARK: Page 2 — Datenschutz

    private var page2: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            VStack(spacing: 10) {
                Text(String(localized: "onboarding.screen2.title",
                            defaultValue: "Halte fest, was bleibt."))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding.screen2.subtitle",
                            defaultValue: "Remember merkt sich wo du warst,\nwas du erlebt hast —\ndamit du es nie vergisst."))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            privacyPoints

            Spacer()

            nextButton { onboardingVM.nextPage() }
            skipButton
        }
        .padding(.bottom, 56)
    }

    // MARK: Page 3 — Standort-Berechtigung

    private var page3: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "location.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color(hex: "#E8593C"))

            VStack(spacing: 10) {
                Text("onboarding.screen3.title")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("onboarding.screen3.subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // ── Made in Munich Footer ─────────────────────────────
            Text(String(localized: "onboarding.screen3.footer",
                        defaultValue: "Remember wurde in München gebaut —\nvon jemandem der glaubt,\ndass die kleinen Momente\ndie grossen ausmachen."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // ── Primärer CTA: Berechtigung anfragen ───────────────
            Button {
                Task {
                    await onboardingVM.requestLocationPermission(manager: locationManager)
                    let status = locationManager.authorizationStatus
                    if status == .denied || status == .restricted {
                        showDeniedScreen = true
                    } else {
                        onboardingVM.completeOnboarding(settings: userSettings)
                        analyticsManager.track(.onboardingCompleted)
                    }
                }
            } label: {
                Group {
                    if onboardingVM.isRequestingPermission {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("onboarding.screen3.cta")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color(hex: "#E8593C"),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
            .disabled(onboardingVM.isRequestingPermission)
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 56)
    }

    // MARK: Reusable Sub-Views

    private var privacyPoints: some View {
        VStack(alignment: .leading, spacing: 14) {
            privacyRow(icon: "iphone",       key: "onboarding.privacy.local")
            privacyRow(icon: "eye.slash",    key: "onboarding.privacy.notracking")
            privacyRow(icon: "person.slash", key: "onboarding.privacy.noaccount")
        }
        .padding(.horizontal, 32)
    }

    private func privacyRow(icon: String, key: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            Text(key)
                .font(.subheadline)
        }
    }

    @ViewBuilder
    private func nextButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("button.next")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color(hex: "#E8593C"),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .padding(.horizontal, 32)
    }

    /// "Überspringen" auf Page 0 und 1 — springt zu Page 2, beendet Onboarding NICHT.
    private var skipButton: some View {
        Button {
            analyticsManager.track(.onboardingSkipped)
            onboardingVM.skipToLocationPage()
        } label: {
            Text("button.skip")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Onboarding Screen") {
    let onboardingVM = OnboardingViewModel()
    let locationMgr  = LocationManager()
    let settings     = UserSettings()
    let analytics    = AnalyticsManager()

    return OnboardingScreen()
        .environment(onboardingVM)
        .environment(locationMgr)
        .environment(settings)
        .environment(analytics)
}
