// EditActivityScreen.swift
// ActivityTracker2 — Remember
// Bearbeitungsansicht für eine bestehende Aktivität

import SwiftUI
import SwiftData

// MARK: - EditActivityScreen

/// Sheet zum Bearbeiten einer Activity. Lokale `@State`-Kopien werden beim `init`
/// aus der Activity initialisiert. Änderungen werden erst beim Tippen auf "Speichern"
/// in die Activity geschrieben und via `ActivityViewModel.updateActivity` persistiert.
struct EditActivityScreen: View {

    // MARK: Parameter

    let activity: Activity

    // MARK: Environment

    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(\.modelContext)         private var modelContext
    @Environment(\.dismiss)              private var dismiss

    // MARK: State (lokale Kopien)

    @State private var editTitle:       String
    @State private var editText:        String
    @State private var editDate:        Date
    @State private var editIsFavorite:  Bool

    @FocusState private var focusedField: Field?

    // MARK: Private

    private enum Field: Hashable {
        case title, text
    }

    // MARK: Init

    /// Initialisiert die lokalen State-Kopien aus der übergebenen Activity.
    init(activity: Activity) {
        self.activity   = activity
        _editTitle      = State(initialValue: activity.title ?? "")
        _editText       = State(initialValue: activity.text ?? "")
        _editDate       = State(initialValue: activity.date)
        _editIsFavorite = State(initialValue: activity.isFavorite)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Kategorie (read-only) ────────────────────────
                    HStack(spacing: 12) {
                        CategoryIconView(categoryId: activity.categoryId, size: 36)
                        Text(activity.displayTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    Divider().padding(.horizontal)

                    // ── Titel ────────────────────────────────────────
                    TextField(
                        String(localized: "add.text.title.placeholder",
                               defaultValue: "Titel (optional)"),
                        text: $editTitle
                    )
                    .font(.headline)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .text }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    Divider().padding(.horizontal)

                    // ── Freitext ────────────────────────────────────
                    TextEditor(text: $editText)
                        .font(.body)
                        .focused($focusedField, equals: .text)
                        .frame(minHeight: 180)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                    Divider().padding(.horizontal)

                    // ── Datum & Uhrzeit ──────────────────────────────
                    DatePicker(
                        String(localized: "add.date.label",
                               defaultValue: "Datum & Uhrzeit"),
                        selection: $editDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    Divider().padding(.horizontal)

                    // ── Favorit ──────────────────────────────────────
                    Toggle(
                        String(localized: "edit.favorite.label",
                               defaultValue: "Favorit"),
                        isOn: $editIsFavorite
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle(String(localized: "edit.title", defaultValue: "Bearbeiten"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "button.save", defaultValue: "Speichern")) {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Save

    private func saveChanges() {
        activity.title      = editTitle.isBlank ? nil : editTitle
        activity.text       = editText.isBlank  ? nil : editText
        activity.date       = editDate
        activity.isFavorite = editIsFavorite
        activityVM.updateActivity(activity, context: modelContext)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Edit Activity Screen") {
    let analytics = AnalyticsManager()
    let actVM     = ActivityViewModel(analytics: analytics)

    return EditActivityScreen(activity: Activity.preview)
        .environment(actVM)
}
