// AddActivityCategoryScreen.swift
// ActivityTracker2 — Remember
// Step 1 des Add-Flows: Kategorie wählen

import SwiftUI

// MARK: - AddActivityCategoryScreen

/// Sheet-Root des 3-Screen-Add-Flows.
/// Zeigt das Kategorie-Grid, navigiert bei Auswahl zu `AddActivityLocationScreen`
/// oder direkt zu `AddActivityTextScreen` (bei journal_home).
/// Schließt das Sheet sobald `addActivityVM.isSaved` gesetzt wird.
struct AddActivityCategoryScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(UserSettings.self)         private var userSettings
    @Environment(StoreKitManager.self)      private var storeKitManager
    @Environment(\.dismiss)                 private var dismiss

    // MARK: State

    /// Bool-gesteuerter Übergang zu Step 2 (Location).
    @State private var navigateToLocation = false

    /// Bool-gesteuerter Übergang direkt zu Step 3 (Text) — bei journal_home.
    @State private var navigateToText = false

    /// Zeigt den HomeLocationSheet beim ersten Tippen auf "journal" ohne gespeichertes Zuhause.
    @State private var showHomePrompt = false

    // MARK: Private

    private var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            CategoryPickerGrid(
                selectedCategoryId: Binding(
                    get: { addActivityVM.selectedCategoryId },
                    set: { newId in
                        guard let newId else { return }
                        addActivityVM.selectedCategoryId = newId

                        if addActivityVM.skipLocationScreen {
                            // Zuhause-Button in journalSection wurde getippt
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToText = true
                            }
                        } else {
                            // Erstes Tippen auf "journal" ohne gespeichertes Zuhause → Prompt
                            if newId == "journal" &&
                               !userSettings.hasHomeLocation &&
                               !UserDefaults.standard.bool(forKey: "hasSeenHomePrompt") {
                                showHomePrompt = true
                            }
                            if !navigateToLocation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToLocation = true
                                }
                            }
                        }
                    }
                ),
                userSettings: userSettings,
                language: language
            )
            .navigationTitle(String(localized: "add.step1.title", defaultValue: "Kategorie"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        addActivityVM.reset()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
            }
            // Navigation zu Step 2 (Ort)
            .navigationDestination(isPresented: $navigateToLocation) {
                AddActivityLocationScreen()
            }
            // Navigation direkt zu Step 3 (Text) — bei journal_home
            .navigationDestination(isPresented: $navigateToText) {
                AddActivityTextScreen()
            }
        }
        .sheet(isPresented: $showHomePrompt) {
            HomeLocationSheet(isShowing: $showHomePrompt)
        }
        .onAppear {
            addActivityVM.reset()
            #if DEBUG
            print("isPlusActive: \(storeKitManager.isPlusActive)")
            print("subscriptionStatus: \(userSettings.subscriptionStatus)")
            #endif
        }
        // Location-Screen dismissed → Auswahl zurücksetzen für Neu-Auswahl
        .onChange(of: navigateToLocation) { _, isActive in
            if !isActive {
                addActivityVM.selectedCategoryId = nil
            }
        }
        // Text-Screen dismissed (direkt) → Auswahl zurücksetzen
        .onChange(of: navigateToText) { _, isActive in
            if !isActive {
                addActivityVM.selectedCategoryId = nil
            }
        }
        // Aktivität gespeichert → Sheet schließen
        .onChange(of: addActivityVM.isSaved) { _, saved in
            if saved {
                addActivityVM.reset()
                dismiss()
            }
        }
        // Zuhause wurde im HomeLocationSheet gesetzt → direkt zu TextScreen
        .onReceive(NotificationCenter.default.publisher(for: .homeLocationSetNavigate)) { _ in
            addActivityVM.useHomeLocation(from: userSettings)
            addActivityVM.skipLocationScreen = true
            addActivityVM.selectedCategoryId = "journal"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                navigateToText = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Add — Step 1: Kategorie") {
    let addVM        = AddActivityViewModel()
    let settings     = UserSettings()
    let storeKitMgr  = StoreKitManager()
    let analytics    = AnalyticsManager()
    let activityVM   = ActivityViewModel(analytics: analytics)

    return AddActivityCategoryScreen()
        .environment(addVM)
        .environment(settings)
        .environment(storeKitMgr)
        .environment(activityVM)
}
