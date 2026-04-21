// SettingsScreen.swift
// ActivityTracker2 — Remember
// App-Einstellungen: Nutzung, Standort, Darstellung, Info, Daten

import SwiftUI
import SwiftData
import UIKit
import CoreLocation

// MARK: - SettingsScreen

/// Einstellungen-Sheet — präsentiert als Modal über MapScreen.
struct SettingsScreen: View {

    // MARK: Environment

    @Environment(UserSettings.self)      private var userSettings
    @Environment(StoreKitManager.self)   private var storeKitManager
    @Environment(LocationManager.self)   private var locationManager
    @Environment(\.dismiss)              private var dismiss

    @Query private var activities: [Activity]

    // MARK: State

    @State private var showPlus       = false
    @State private var showHomeSearch = false

    // MARK: Private

    private var isPlusUser: Bool {
        storeKitManager.isPlusActive || userSettings.subscriptionStatus.isPremium
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            List {

                // ── Mitgliedschaft ────────────────────────────────
                Section(L10n.settingsMembership) {

                    if isPlusUser {

                        HStack {
                            Label(L10n.settingsCurrentPlan, systemImage: "crown.fill")
                            Spacer()
                            Text(L10n.settingsPlus)
                                .foregroundStyle(Color(hex: "#FFD700"))
                                .fontWeight(.semibold)
                        }

                        Text(String(localized: "settings.plan.plus_detail",
                                    defaultValue: "Unbegrenzte Aktivitäten"))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                    } else {

                        HStack {
                            Label(L10n.settingsCurrentPlan, systemImage: "crown.fill")
                            Spacer()
                            Text(L10n.settingsFree)
                                .foregroundStyle(.secondary)
                        }

                        Text(String(localized: "settings.plan.free_detail",
                                    defaultValue: "100 Aktivitäten kostenlos"))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Label(L10n.settingsActivities, systemImage: "chart.bar.fill")
                            Spacer()
                            Text(String(format: L10n.settingsActivitiesCount,
                                        activities.count))
                                .foregroundStyle(activities.count > 80 ? Color.red : Color.secondary)
                        }

                        Button {
                            showPlus = true
                        } label: {
                            HStack {
                                Label(L10n.settingsDiscoverPlus, systemImage: "star.fill")
                                    .foregroundStyle(Color(hex: "#E8593C"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ── Standort ─────────────────────────────────────
                Section(L10n.settingsLocation) {

                    // GPS Status
                    HStack {
                        Label(
                            L10n.settingsGPS,
                            systemImage: locationManager.authorizationStatus == .denied
                                ? "location.slash.fill"
                                : "location.fill"
                        )
                        Spacer()
                        Text(locationManager.authorizationStatus == .denied
                             ? L10n.settingsGPSDenied
                             : L10n.settingsGPSActive)
                            .font(.caption)
                            .foregroundStyle(
                                locationManager.authorizationStatus == .denied
                                    ? .red : .green
                            )
                    }

                    if locationManager.authorizationStatus == .denied {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label(L10n.settingsEnableGPS, systemImage: "gear")
                                .foregroundStyle(Color(hex: "#E8593C"))
                        }
                    }

                    if userSettings.hasHomeLocation {
                        HStack {
                            Label(
                                userSettings.homeName ?? L10n.settingsHome,
                                systemImage: "house.fill"
                            )
                            .lineLimit(1)
                            Spacer()
                            Button(L10n.settingsChange) {
                                showHomeSearch = true
                            }
                            .foregroundStyle(Color(hex: "#E8593C"))
                            .font(.caption)

                            Button {
                                userSettings.clearHomeLocation()
                                UserDefaults.standard.removeObject(forKey: "hasSeenHomePrompt")
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Button {
                            showHomeSearch = true
                        } label: {
                            Label(L10n.settingsAddHome, systemImage: "house.badge.plus")
                                .foregroundStyle(Color(hex: "#E8593C"))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ── Darstellung ───────────────────────────────────
                Section(L10n.settingsAppearance) {

                    HStack {
                        Label(L10n.settingsMapStyle, systemImage: "map")
                        Spacer()
                        Picker("", selection: Binding(
                            get: { userSettings.mapStyle },
                            set: { userSettings.mapStyle = $0 }
                        )) {
                            Text(L10n.settingsStandard).tag("standard")
                            Text(L10n.settingsSatellite).tag("satellite")
                            Text(L10n.settingsHybrid).tag("hybrid")
                        }
                        .pickerStyle(.menu)
                    }
                }

                // ── App Info ──────────────────────────────────────
                Section(L10n.settingsAppInfo) {

                    HStack {
                        Label(L10n.settingsVersion, systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label(L10n.settingsDeveloper, systemImage: "person.fill")
                        Spacer()
                        Text("F. Klepper")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label(L10n.settingsWebsite, systemImage: "globe")
                        Spacer()
                        Link("remember-journal.com",
                             destination: URL(string: "https://remember-journal.com")!)
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                }

                // ── Rechtliches ───────────────────────────────────
                Section(L10n.settingsLegal) {

                    // Impressum
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.settingsImprint)
                            .font(.headline)
                            .padding(.bottom, 4)

                        Text(String(localized: "settings.legal.imprint.type",
                                    defaultValue: "Einzelunternehmen"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("F. Klepper")
                            .font(.subheadline)
                        Text("82418 Murnau am Staffelsee")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Bayern, Deutschland")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Divider()
                            .padding(.vertical, 4)

                        Link("support@remember-journal.com",
                             destination: URL(string: "mailto:support@remember-journal.com")!)
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "#E8593C"))

                        Link("remember-journal.com",
                             destination: URL(string: "https://remember-journal.com")!)
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                    .padding(.vertical, 8)

                    // Datenschutzerklärung
                    Link(destination: URL(string: "https://remember-journal.com/datenschutz.html")!) {
                        HStack {
                            Label(L10n.settingsPrivacy, systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    // Nutzungsbedingungen
                    Link(destination: URL(string: "https://remember-journal.com/nutzungsbedingungen.html")!) {
                        HStack {
                            Label(L10n.settingsTerms, systemImage: "doc.text.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    // Feedback
                    Link(destination: URL(string: "mailto:support@remember-journal.com")!) {
                        HStack {
                            Label(L10n.settingsFeedback, systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // ── Made in Munich ────────────────────────────────
                Section {
                    VStack(spacing: 4) {
                        Text("🇩🇪 \(L10n.indieApp)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text(L10n.madeIn)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        Text(L10n.privacyFooter)
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .preferredColorScheme(
            userSettings.colorScheme == "light" ? .light :
            userSettings.colorScheme == "dark"  ? .dark  : nil
        )
        .sheet(isPresented: $showPlus) {
            PlusScreen(source: "settings")
        }
        .sheet(isPresented: $showHomeSearch) {
            HomeLocationSheet(isShowing: $showHomeSearch)
        }
    }

    // MARK: Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview("Settings Screen") {
    SettingsScreen()
        .environment(UserSettings())
        .environment(StoreKitManager())
        .environment(LocationManager())
}
