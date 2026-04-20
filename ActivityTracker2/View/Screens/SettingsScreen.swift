// SettingsScreen.swift
// ActivityTracker2 — Remember
// App-Einstellungen: Nutzung, Standort, Darstellung, Info, Daten

import SwiftUI
import SwiftData

// MARK: - SettingsScreen

/// Einstellungen-Sheet — präsentiert als Modal über MapScreen.
struct SettingsScreen: View {

    // MARK: Environment

    @Environment(UserSettings.self)      private var userSettings
    @Environment(StoreKitManager.self)   private var storeKitManager
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
                Section(String(localized: "settings.section.membership")) {

                    // Aktueller Plan
                    HStack {
                        Label(
                            String(localized: "settings.plan.current"),
                            systemImage: "crown.fill"
                        )
                        .foregroundStyle(.primary)
                        Spacer()
                        Text(isPlusUser
                             ? String(localized: "settings.plan.plus")
                             : String(localized: "settings.plan.free"))
                            .foregroundStyle(.secondary)
                    }

                    // Plus entdecken — nur für Free-User
                    if !isPlusUser {
                        Button {
                            showPlus = true
                        } label: {
                            HStack {
                                Label(
                                    String(localized: "settings.plan.discover"),
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
                }

                // ── Nutzung ───────────────────────────────────────
                Section(String(localized: "settings.section.usage")) {

                    VStack(spacing: 8) {
                        HStack {
                            Label(
                                String(localized: "settings.activities"),
                                systemImage: "chart.bar.fill"
                            )
                            Spacer()
                            if isPlusUser {
                                // Plus: kein Limit — Zahl + ∞-Icon, immer secondary
                                Text("\(activities.count)")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "infinity")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            } else {
                                // Free: Zahl/100, rot wenn > 80
                                Text("\(activities.count) / \(AppConstants.freeActivityLimit)")
                                    .foregroundStyle(
                                        activities.count > 80 ? Color.red : Color.secondary
                                    )
                            }
                        }

                        if !isPlusUser {
                            ProgressView(
                                value: Double(min(activities.count, AppConstants.freeActivityLimit)),
                                total: Double(AppConstants.freeActivityLimit)
                            )
                            .tint(activities.count > 80 ? .red : Color(hex: "#E8593C"))
                        }
                    }
                    .padding(.vertical, 4)
                }

                // ── Standort ─────────────────────────────────────
                Section(String(localized: "settings.section.location")) {

                    if userSettings.hasHomeLocation {
                        HStack {
                            Label(
                                userSettings.homeLocationName.isEmpty
                                    ? String(localized: "settings.home.default")
                                    : userSettings.homeLocationName,
                                systemImage: "house.fill"
                            )
                            .lineLimit(1)
                            Spacer()
                            Button(String(localized: "settings.home.change",
                                          defaultValue: "Ändern")) {
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
                            Label(
                                String(localized: "settings.home.add",
                                       defaultValue: "Zuhause hinzufügen"),
                                systemImage: "house.badge.plus"
                            )
                            .foregroundStyle(Color(hex: "#E8593C"))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ── Darstellung ───────────────────────────────────
                Section(String(localized: "settings.section.appearance")) {

                    HStack {
                        Label(
                            String(localized: "settings.color.scheme"),
                            systemImage: "circle.lefthalf.filled"
                        )
                        Spacer()
                        Picker("", selection: Binding(
                            get: { userSettings.colorScheme },
                            set: { userSettings.colorScheme = $0 }
                        )) {
                            Text(String(localized: "settings.scheme.system")).tag("system")
                            Text(String(localized: "settings.scheme.light")).tag("light")
                            Text(String(localized: "settings.scheme.dark")).tag("dark")
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Label(
                            String(localized: "settings.map.style"),
                            systemImage: "map"
                        )
                        Spacer()
                        Picker("", selection: Binding(
                            get: { userSettings.mapStyle },
                            set: { userSettings.mapStyle = $0 }
                        )) {
                            Text(String(localized: "settings.map.standard")).tag("standard")
                            Text(String(localized: "settings.map.satellite")).tag("satellite")
                            Text(String(localized: "settings.map.hybrid")).tag("hybrid")
                        }
                        .pickerStyle(.menu)
                    }
                }

                // ── App Info ──────────────────────────────────────
                Section(String(localized: "settings.section.info")) {

                    HStack {
                        Label(
                            String(localized: "settings.version"),
                            systemImage: "info.circle"
                        )
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label(
                            String(localized: "settings.developer"),
                            systemImage: "person.fill"
                        )
                        Spacer()
                        Text("F. Klepper")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label(
                            String(localized: "settings.website"),
                            systemImage: "globe"
                        )
                        Spacer()
                        Link("remember-journal.com",
                             destination: URL(string: "https://remember-journal.com")!)
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                }

                // ── Rechtliches ───────────────────────────────────
                Section(String(localized: "settings.section.legal")) {

                    // Impressum
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "settings.legal.imprint"))
                            .font(.headline)
                            .padding(.bottom, 4)

                        Text(String(localized: "settings.legal.imprint.type"))
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
                            Label(
                                String(localized: "settings.privacy"),
                                systemImage: "hand.raised.fill"
                            )
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
                            Label(
                                String(localized: "settings.terms"),
                                systemImage: "doc.text.fill"
                            )
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
                            Label(
                                String(localized: "settings.feedback"),
                                systemImage: "envelope.fill"
                            )
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // ── Daten ─────────────────────────────────────────
                Section(String(localized: "settings.section.data")) {

                    Button(role: .destructive) {
                        userSettings.hasCompletedOnboarding = false
                    } label: {
                        Label(
                            String(localized: "settings.reset.onboarding"),
                            systemImage: "arrow.counterclockwise"
                        )
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
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
}
