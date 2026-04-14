// AppState.swift
// ActivityTracker2 — Remember

import Foundation

// MARK: - AppState

@Observable
final class AppState {
    static let shared = AppState()
    private init() {}

    /// `true` wenn das PermanentBottomSheet auf .large steht — steuert Tab Bar Farben.
    var isSheetLarge: Bool = false
}
