// AnalyticsManager.swift
// ActivityTracker2 — Remember
// Analytics-Tracking — Debug: Konsolen-Output / Release: TODO Firebase/Amplitude

import Foundation

// MARK: - AnalyticsManager

/// Zentraler Analytics-Manager der App.
/// Im DEBUG-Modus werden Events auf der Konsole geloggt.
/// Im RELEASE-Modus ist der Manager ein No-op — Firebase/Amplitude werden hier integriert,
/// sobald ein Analytics-SDK hinzugefügt wird.
///
/// Events werden in einem unstrukturierten `Task` nicht-blockierend getracked.
@Observable
final class AnalyticsManager {

    // MARK: Init

    init() {}

    // MARK: Tracking

    /// Tracked ein Analytics-Event nicht-blockierend.
    /// Aufruf ist fire-and-forget — der Caller wartet nicht auf Completion.
    /// - Parameter event: Das zu trackende Event aus `AnalyticsEvent`.
    func track(_ event: AnalyticsEvent) {
        Task {
            await log(event)
        }
    }
}

// MARK: - Private Logging

private extension AnalyticsManager {

    /// Führt das tatsächliche Logging aus — im DEBUG auf Konsole, im Release No-op.
    func log(_ event: AnalyticsEvent) async {
        #if DEBUG
        let params = event.parameters
        if params.isEmpty {
            print("[Analytics] \(event.eventName)")
        } else {
            let formatted = params
                .sorted { $0.key < $1.key }
                .map { "\($0.key): \($0.value)" }
                .joined(separator: ", ")
            print("[Analytics] \(event.eventName) — \(formatted)")
        }
        #else
        // TODO: Firebase Analytics Integration
        // Analytics.logEvent(event.eventName, parameters: event.parameters)

        // TODO: Amplitude Integration (Alternative)
        // Amplitude.instance().logEvent(event.eventName, withEventProperties: event.parameters)
        _ = event // Unterdrückt "unused variable"-Warnung im Release-Build
        #endif
    }
}
