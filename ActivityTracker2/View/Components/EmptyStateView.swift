// EmptyStateView.swift
// ActivityTracker2 — Remember
// Leerzustands-Ansicht mit konfigurierbarem Icon, Text und optionalem CTA

import SwiftUI

// MARK: - EmptyStateConfig

/// Konfigurationsobjekt für `EmptyStateView`.
struct EmptyStateConfig {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}

// MARK: - Statische Presets

extension EmptyStateConfig {

    /// Kein Eintrag vorhanden — erster Start oder alles gelöscht.
    static var noActivities: EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "map",
            title: String(localized: "empty.no_activities.title",
                          defaultValue: "Noch keine Momente"),
            message: String(localized: "empty.no_activities.message",
                            defaultValue: "Heute noch nichts erlebt?\nManchmal ist Pause auch ein Moment.")
        )
    }

    /// Aktueller Filter hat keine Treffer.
    static var filteredNoResults: EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "line.3.horizontal.decrease",
            title: String(localized: "empty.filtered.title",
                          defaultValue: "Keine Treffer"),
            message: String(localized: "empty.filtered.message",
                            defaultValue: "Für diesen Filter gibt es noch keine Einträge.")
        )
    }

    /// Activity-Limit erreicht — Plus-CTA.
    static func limitReached(action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "lock.fill",
            title: String(localized: "empty.limit_reached.title",
                          defaultValue: "Limit erreicht"),
            message: String(localized: "empty.limit_reached.message",
                            defaultValue: "Mit Remember Plus hältst du unbegrenzt Momente fest."),
            actionTitle: String(localized: "empty.limit_reached.cta",
                                defaultValue: "Plus entdecken"),
            action: action
        )
    }

    /// Keine Aktivitäten in einer bestimmten Kategorie.
    static func forCategory(name: String, icon: String) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "map",
            title: String(localized: "empty.no_activities.title",
                          defaultValue: "Noch keine Momente"),
            message: "Noch keine \(name) dabei.\nZeit für ein Abenteuer? \(icon)"
        )
    }
}

// MARK: - EmptyStateView

/// Zentrierte Leerzustands-Ansicht: Icon, Titel, Text und optionaler Button.
struct EmptyStateView: View {

    // MARK: Parameter

    let config: EmptyStateConfig

    // MARK: Body

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: config.systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(config.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text(config.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionTitle = config.actionTitle,
               let action = config.action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#E8593C"), in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview("Empty States") {
    TabView {
        EmptyStateView(config: .noActivities)
            .tabItem { Label("Keine Einträge", systemImage: "map") }

        EmptyStateView(config: .filteredNoResults)
            .tabItem { Label("Kein Treffer", systemImage: "line.3.horizontal.decrease") }

        EmptyStateView(config: .limitReached(action: {}))
            .tabItem { Label("Limit", systemImage: "lock.fill") }

        EmptyStateView(config: .forCategory(name: "Wanderungen", icon: "🥾"))
            .tabItem { Label("Kategorie", systemImage: "figure.hiking") }
    }
}
