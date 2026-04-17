// AddActivityTextScreen.swift
// ActivityTracker2 — Remember
// Step 3 des Add-Flows: Titel, Text und Datum eingeben

import SwiftUI
import SwiftData

// MARK: - AddActivityTextScreen

/// Screen 3 des Add-Flows. Bietet Titel- und Textfelder sowie eine Datumsauswahl.
/// Nach erfolgreichem Speichern wird `addActivityVM.isSaved = true` gesetzt, was
/// `AddActivityCategoryScreen` veranlasst, das Sheet zu schließen.
struct AddActivityTextScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(ActivityViewModel.self)    private var activityVM
    @Environment(\.modelContext)            private var modelContext

    // MARK: State

    /// Fokussiertes Textfeld im Formular.
    @FocusState private var focusedField: Field?

    /// Steuert das Datumsauswahl-Sheet.
    @State private var showDatePicker = false

    /// Fehlermeldung nach einem fehlgeschlagenen Speichervorgang.
    @State private var saveError: String? = nil

    // MARK: Private

    private enum Field: Hashable {
        case title, text
    }

    // MARK: Body

    var body: some View {
        @Bindable var vm = addActivityVM

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // ── Titelzeile ──────────────────────────────────────
                TextField(
                    String(localized: "add.text.title.placeholder",
                           defaultValue: "Titel"),
                    text: $vm.title
                )
                .font(.headline)
                .focused($focusedField, equals: .title)
                .submitLabel(.return)
                .onSubmit { focusedField = .text }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // ── Freitext ────────────────────────────────────────
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.text)
                        .font(.body)
                        .focused($focusedField, equals: .text)
                        .frame(minHeight: 220)

                    if vm.text.isEmpty {
                        Text(String(localized: "add.text.body.placeholder",
                                    defaultValue: "Text"))
                            .font(.body)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 12)

                // ── Sterne-Bewertung ────────────────────────────────
                StarRatingView(
                    rating: Binding(
                        get: { addActivityVM.starRating },
                        set: { addActivityVM.starRating = $0 }
                    ),
                    isEditable: true
                )
                .padding(.top, 16)

                // ── Fehler ──────────────────────────────────────────
                if let error = saveError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle(String(localized: "add.step3.title", defaultValue: "Eintrag"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Speichern-Button oben rechts
            ToolbarItem(placement: .topBarTrailing) {
                if addActivityVM.isLoading {
                    ProgressView()
                } else {
                    Button(String(localized: "button.save", defaultValue: "Speichern")) {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                }
            }
            // Datum-Button unten links
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        showDatePicker = true
                    } label: {
                        Label(
                            addActivityVM.selectedDate.formattedActivityDate,
                            systemImage: "calendar"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $vm.selectedDate)
        }
        .onAppear {
            focusedField = .title
        }
    }

    // MARK: Save

    private func save() async {
        saveError = nil
        do {
            try await addActivityVM.saveActivity(
                activityViewModel: activityVM,
                context: modelContext
            )
            addActivityVM.isSaved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .setSheetMedium, object: nil)
            }
        } catch {
            saveError = String(
                localized: "add.save.error",
                defaultValue: "Speichern fehlgeschlagen. Bitte erneut versuchen."
            )
        }
    }
}

// MARK: - DatePickerSheet

/// Inline-Datumswähler als Sheet. Zeigt Datum und Uhrzeit.
private struct DatePickerSheet: View {

    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DatePicker(
                String(localized: "add.date.label", defaultValue: "Datum & Uhrzeit"),
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle(String(localized: "add.date.title", defaultValue: "Datum wählen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "button.done", defaultValue: "Fertig")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview("Add — Step 3: Text") {
    let analytics = AnalyticsManager()
    let addVM     = AddActivityViewModel()
    let actVM     = ActivityViewModel(analytics: analytics)

    addVM.selectedCategoryId  = "hiking"
    addVM.pendingLocationName = "München, Bayern"

    return NavigationStack {
        AddActivityTextScreen()
    }
    .environment(addVM)
    .environment(actVM)
    // modelContext via @Environment(\.modelContext) wird im Preview
    // vom SwiftUI-Previews-Container bereitgestellt
}
