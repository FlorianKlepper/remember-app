// LocationPermissionDeniedScreen.swift
// ActivityTracker2 — Remember
// Sackgassen-Screen bei verweigerter GPS-Berechtigung

import SwiftUI

// MARK: - LocationPermissionDeniedScreen

/// Wird angezeigt wenn der User die Standort-Berechtigung verweigert hat.
/// Remember benötigt GPS zwingend — kein Weiterkommen ohne Berechtigung.
/// Einziger Ausweg: Berechtigung in den iOS-Einstellungen erteilen.
struct LocationPermissionDeniedScreen: View {

    // MARK: Environment

    @Environment(\.openURL) private var openURL

    // MARK: Body

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.slash.fill")
                .font(.system(size: 72))
                .foregroundStyle(.red)

            VStack(spacing: 10) {
                Text("location.denied.title")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("location.denied.message")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // ── Einstellungen öffnen ─────────────────────────────
            Button {
                // "app-settings:" öffnet die App-Seite in den iOS-Einstellungen
                if let settingsURL = URL(string: "app-settings:") {
                    openURL(settingsURL)
                }
            } label: {
                Text("location.denied.settings_button")
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
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Preview

#Preview("Location Permission Denied") {
    LocationPermissionDeniedScreen()
}
