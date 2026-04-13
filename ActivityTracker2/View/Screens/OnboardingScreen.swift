// OnboardingScreen.swift
// ActivityTracker2 — Remember
// 3-seitiger Onboarding-Flow: App-Wert → Datenschutz → Standort-Berechtigung

import SwiftUI

// MARK: - OnboardingScreen

/// Vollbild-Onboarding mit `TabView(.page)` — 3 Screens.
/// Screen 0: App-Wert + Sprachauswahl
/// Screen 1: Datenschutz-Versprechen
/// Screen 2: Standort-Berechtigung (iOS-Dialog vorher anzeigen)
struct OnboardingScreen: View {

    // MARK: Environment

    @Environment(OnboardingViewModel.self) private var onboardingVM
    @Environment(LocationManager.self)     private var locationManager
    @Environment(UserSettings.self)        private var userSettings
    @Environment(AnalyticsManager.self)    private var analyticsManager
    @Environment(LanguageManager.self)     private var languageManager

    // MARK: State

    /// Gewählte Sprache — temporär bis Onboarding abgeschlossen.
    @State private var selectedLanguage: String = "system"

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

    // MARK: Page 1 — App-Wert & Sprachauswahl

    private var page1: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "map.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color(hex: "#E8593C"))

            VStack(spacing: 10) {
                Text("onboarding.screen1.title")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("onboarding.screen1.subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // ── Sprachauswahl ────────────────────────────────────
            Picker(
                String(localized: "onboarding.language.label",
                       defaultValue: "Sprache"),
                selection: $selectedLanguage
            ) {
                Text("onboarding.language.system").tag("system")
                Text("Deutsch").tag("de")
                Text("English").tag("en")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)

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
                Text("onboarding.screen2.title")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("onboarding.screen2.subtitle")
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

            Spacer()

            // ── Primärer CTA: Berechtigung anfragen ───────────────
            Button {
                Task {
                    await onboardingVM.requestLocationPermission(manager: locationManager)
                    onboardingVM.completeOnboarding(
                        settings: userSettings,
                        language: selectedLanguage
                    )
                    languageManager.selectedLanguage = selectedLanguage
                    analyticsManager.track(.onboardingCompleted)
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

            // ── Sekundärer Link: Sackgassen-Screen ────────────────
            // Kein "Überspringen" — wer den Link tippt landet im
            // LocationPermissionDeniedScreen ohne Weiterkommen-Option.
            Button {
                showDeniedScreen = true
            } label: {
                Text("onboarding.screen3.skip")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 56)
    }

    // MARK: Reusable Sub-Views

    private var privacyPoints: some View {
        VStack(alignment: .leading, spacing: 14) {
            privacyRow(icon: "iphone",      key: "onboarding.privacy.local")
            privacyRow(icon: "eye.slash",   key: "onboarding.privacy.notracking")
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
    let onboardingVM  = OnboardingViewModel()
    let locationMgr   = LocationManager()
    let settings      = UserSettings()
    let analytics     = AnalyticsManager()
    let languageMgr   = LanguageManager()

    return OnboardingScreen()
        .environment(onboardingVM)
        .environment(locationMgr)
        .environment(settings)
        .environment(analytics)
        .environment(languageMgr)
}
