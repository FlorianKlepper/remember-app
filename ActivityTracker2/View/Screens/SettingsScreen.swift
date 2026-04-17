// SettingsScreen.swift
// ActivityTracker2 — Remember
// App-Einstellungen: Sprache, Standort, Darstellung, Info, Daten

import SwiftUI

// MARK: - SettingsScreen

/// Einstellungen-Sheet — präsentiert als Modal über MapScreen.
struct SettingsScreen: View {

    // MARK: Environment

    @Environment(UserSettings.self)    private var userSettings
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss)            private var dismiss

    // MARK: State

    @State private var showPlus = false

    // MARK: Body

    var body: some View {
        NavigationStack {
            List {

                // ── Mitgliedschaft ────────────────────────────────
                Section(String(localized: "settings.section.membership",
                               defaultValue: "Mitgliedschaft")) {

                    // Aktueller Plan
                    HStack {
                        Label(
                            String(localized: "settings.plan.current",
                                   defaultValue: "Aktueller Plan"),
                            systemImage: "crown.fill"
                        )
                        .foregroundStyle(.primary)
                        Spacer()
                        Text(userSettings.subscriptionStatus.isPremium
                             ? String(localized: "settings.plan.plus",
                                      defaultValue: "Remember Plus")
                             : String(localized: "settings.plan.free",
                                      defaultValue: "Kostenlos"))
                            .foregroundStyle(.secondary)
                    }

                    // Plus entdecken — nur für Free-User
                    if !userSettings.subscriptionStatus.isPremium {
                        Button {
                            showPlus = true
                        } label: {
                            HStack {
                                Label(
                                    String(localized: "settings.plan.discover",
                                           defaultValue: "Remember Plus entdecken"),
                                    systemImage: "star.fill"
                                )
                                .foregroundStyle(Color(hex: "#E8593C"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Aktivitäten-Zähler
                    HStack {
                        Label(
                            String(localized: "settings.activities",
                                   defaultValue: "Aktivitäten"),
                            systemImage: "chart.bar.fill"
                        )
                        Spacer()
                        Text(userSettings.subscriptionStatus.isPremium
                             ? "\(userSettings.activitiesCreatedCount)"
                             : "\(userSettings.activitiesCreatedCount) / \(AppConstants.freeActivityLimit)")
                            .foregroundStyle(.secondary)
                    }
                }

                // ── Sprache ──────────────────────────────────────
                Section(String(localized: "settings.section.language",
                               defaultValue: "Sprache")) {

                    languageRow(code: "de",
                                label: String(localized: "language.de",
                                              defaultValue: "Deutsch"))

                    languageRow(code: "en",
                                label: String(localized: "language.en",
                                              defaultValue: "English"))
                }

                // ── Standort ─────────────────────────────────────
                Section(String(localized: "settings.section.location",
                               defaultValue: "Standort")) {

                    if userSettings.hasHomeLocation {
                        HStack {
                            Label(
                                userSettings.homeLocationName.isEmpty
                                    ? String(localized: "settings.home.default",
                                             defaultValue: "Zuhause")
                                    : userSettings.homeLocationName,
                                systemImage: "house.fill"
                            )
                            .lineLimit(1)
                            Spacer()
                            Button(String(localized: "settings.home.remove",
                                         defaultValue: "Entfernen")) {
                                userSettings.clearHomeLocation()
                            }
                            .foregroundStyle(Color(hex: "#E8593C"))
                            .font(.caption)
                        }
                    } else {
                        Label(
                            String(localized: "settings.home.empty",
                                   defaultValue: "Kein Zuhause gesetzt"),
                            systemImage: "house"
                        )
                        .foregroundStyle(.secondary)
                    }
                }

                // ── Darstellung ───────────────────────────────────
                Section(String(localized: "settings.section.appearance",
                               defaultValue: "Darstellung")) {

                    HStack {
                        Label(
                            String(localized: "settings.color.scheme",
                                   defaultValue: "Erscheinungsbild"),
                            systemImage: "circle.lefthalf.filled"
                        )
                        Spacer()
                        Picker("", selection: Binding(
                            get: { userSettings.colorScheme },
                            set: { userSettings.colorScheme = $0 }
                        )) {
                            Text(String(localized: "settings.scheme.system",
                                        defaultValue: "System")).tag("system")
                            Text(String(localized: "settings.scheme.light",
                                        defaultValue: "Hell")).tag("light")
                            Text(String(localized: "settings.scheme.dark",
                                        defaultValue: "Dunkel")).tag("dark")
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Label(
                            String(localized: "settings.map.style",
                                   defaultValue: "Karten-Stil"),
                            systemImage: "map"
                        )
                        Spacer()
                        Picker("", selection: Binding(
                            get: { userSettings.mapStyle },
                            set: { userSettings.mapStyle = $0 }
                        )) {
                            Text(String(localized: "settings.map.standard",
                                        defaultValue: "Standard")).tag("standard")
                            Text(String(localized: "settings.map.satellite",
                                        defaultValue: "Satellit")).tag("satellite")
                            Text(String(localized: "settings.map.hybrid",
                                        defaultValue: "Hybrid")).tag("hybrid")
                        }
                        .pickerStyle(.menu)
                    }
                }

                // ── App Info ──────────────────────────────────────
                Section(String(localized: "settings.section.info",
                               defaultValue: "Info")) {

                    HStack {
                        Label(
                            String(localized: "settings.version",
                                   defaultValue: "Version"),
                            systemImage: "info.circle"
                        )
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "mailto:f.klepper@gmx.de")!) {
                        Label(
                            String(localized: "settings.feedback",
                                   defaultValue: "Feedback senden"),
                            systemImage: "envelope"
                        )
                    }
                }

                // ── Rechtliches ───────────────────────────────────
                Section(String(localized: "settings.section.legal",
                               defaultValue: "Rechtliches")) {

                    // Impressum
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "settings.legal.imprint",
                                    defaultValue: "Impressum"))
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Text("Florian Klepper")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Link("f.klepper@gmx.de",
                             destination: URL(string: "mailto:f.klepper@gmx.de")!)
                            .font(.caption)
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                    .padding(.vertical, 4)

                    Link(destination: URL(string: "https://remember-app.de/privacy")!) {
                        Label(
                            String(localized: "settings.privacy",
                                   defaultValue: "Datenschutzerklärung"),
                            systemImage: "lock.fill"
                        )
                    }

                    Link(destination: URL(string: "https://remember-app.de/terms")!) {
                        Label(
                            String(localized: "settings.terms",
                                   defaultValue: "Nutzungsbedingungen"),
                            systemImage: "doc.text"
                        )
                    }
                }

                // ── Daten ─────────────────────────────────────────
                Section(String(localized: "settings.section.data",
                               defaultValue: "Daten")) {

                    Button(role: .destructive) {
                        userSettings.hasCompletedOnboarding = false
                    } label: {
                        Label(
                            String(localized: "settings.reset.onboarding",
                                   defaultValue: "Onboarding zurücksetzen"),
                            systemImage: "arrow.counterclockwise"
                        )
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title",
                                    defaultValue: "Einstellungen"))
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
            PlusScreen()
        }
    }

    // MARK: Helpers

    private func languageRow(code: String, label: String) -> some View {
        HStack {
            Label(label, systemImage: "globe")
            Spacer()
            if languageManager.currentLanguageCode == code {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color(hex: "#E8593C"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            languageManager.applyLanguage(code)
            userSettings.selectedLanguage = code
        }
    }

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
        .environment(LanguageManager())
}
