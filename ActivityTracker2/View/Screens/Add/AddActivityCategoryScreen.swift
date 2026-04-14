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

    /// NavigationPath für den 3-stufigen Add-Flow.
    @State private var navigationPath = NavigationPath()

    // MARK: Private

    private var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    // MARK: Body

    var body: some View {
        @Bindable var vm = addActivityVM

        NavigationStack(path: $navigationPath) {
            CategoryPickerGrid(
                selectedCategoryId: $vm.selectedCategoryId,
                userSettings: userSettings,
                language: language
            )
            .navigationTitle(String(localized: "add.step1.title", defaultValue: "Kategorie"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        addActivityVM.reset()
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: Int.self) { step in
                if step == 2 {
                    AddActivityLocationScreen(navigationPath: $navigationPath)
                } else if step == 3 {
                    AddActivityTextScreen()
                }
            }
        }
        // Kategorie ausgewählt → zu Schritt 2 (Ort) navigieren
        .onChange(of: addActivityVM.selectedCategoryId) { _, newValue in
            guard newValue != nil else { return }
            // Nur pushen wenn noch nicht auf LocationScreen
            if navigationPath.count == 0 {
                navigationPath.append(2)
            }
        }
        // User ist von LocationScreen zurückgekehrt → Auswahl zurücksetzen für Neu-Auswahl
        .onChange(of: navigationPath.count) { oldCount, newCount in
            if oldCount > 0 && newCount == 0 {
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
