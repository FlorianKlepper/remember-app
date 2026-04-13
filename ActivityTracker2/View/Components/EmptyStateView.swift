// EmptyStateView.swift
// ActivityTracker2 — Remember
// Leerzustands-Ansicht mit konfigurierbarem Icon, Text und optionalem CTA

import SwiftUI

// MARK: - EmptyStateConfig

/// Konfigurationsobjekt für `EmptyStateView`.
struct EmptyStateConfig {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
    let actionTitleKey: LocalizedStringKey?
    let action: (() -> Void)?

    init(
        systemImage: String,
        titleKey: LocalizedStringKey,
        messageKey: LocalizedStringKey,
        actionTitleKey: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.titleKey = titleKey
        self.messageKey = messageKey
        self.actionTitleKey = actionTitleKey
        self.action = action
    }
}

// MARK: - Statische Presets

extension EmptyStateConfig {

    /// Kein Eintrag vorhanden — erster Start oder alles gelöscht.
    static var noActivities: EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "map",
            titleKey: "empty.no_activities.title",
            messageKey: "empty.no_activities.message"
        )
    }

    /// Aktueller Filter hat keine Treffer.
    static var filteredNoResults: EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "line.3.horizontal.decrease",
            titleKey: "empty.filtered.title",
            messageKey: "empty.filtered.message"
        )
    }

    /// Activity-Limit erreicht — Plus-CTA.
    static func limitReached(action: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            systemImage: "lock.fill",
            titleKey: "empty.limit_reached.title",
            messageKey: "empty.limit_reached.message",
            actionTitleKey: "empty.limit_reached.cta",
            action: action
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

            Text(config.titleKey)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text(config.messageKey)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let actionTitleKey = config.actionTitleKey,
               let action = config.action {
                Button(action: action) {
                    Text(actionTitleKey)
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
    }
}
