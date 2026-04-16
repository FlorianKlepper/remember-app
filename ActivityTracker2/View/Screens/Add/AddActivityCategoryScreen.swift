// AddActivityCategoryScreen.swift
// ActivityTracker2 — Remember
// Step 1 des Add-Flows: Kategorie wählen

import SwiftUI

// MARK: - AddActivityCategoryScreen

/// Sheet-Root des 3-Screen-Add-Flows.
/// Zeigt das Kategorie-Grid, navigiert bei Auswahl zu `AddActivityLocationScreen`
/// und schließt das Sheet sobald `addActivityVM.isSaved` gesetzt wird.
struct AddActivityCategoryScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(UserSettings.self)         private var userSettings
    @Environment(\.dismiss)                 private var dismiss

    // MARK: State

    /// NavigationPath für den Step 2 → Step 3 Übergang innerhalb des Flows.
    @State private var navigationPath = NavigationPath()

    /// Bool-gesteuerter Übergang zu Step 2 — verhindert Doppel-Navigation.
    @State private var navigateToLocation = false

    // MARK: Private

    private var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    // MARK: Body

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CategoryPickerGrid(
                selectedCategoryId: Binding(
                    get: { addActivityVM.selectedCategoryId },
                    set: { newId in
                        addActivityVM.selectedCategoryId = newId
                        if newId != nil, !navigateToLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToLocation = true
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
            // Navigation zu Step 2 via Bool — nie doppelt
            .navigationDestination(isPresented: $navigateToLocation) {
                AddActivityLocationScreen(navigationPath: $navigationPath)
            }
        }
        // LocationScreen dismissed → Auswahl zurücksetzen für Neu-Auswahl
        .onChange(of: navigateToLocation) { _, isActive in
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
    }
}

// MARK: - Preview

#Preview("Add — Step 1: Kategorie") {
    let addVM    = AddActivityViewModel()
    let settings = UserSettings()

    return AddActivityCategoryScreen()
        .environment(addVM)
        .environment(settings)
}
