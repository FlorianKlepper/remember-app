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

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(UserSettings.self)       private var userSettings
    @Environment(LanguageManager.self)    private var languageManager
    @Environment(\.modelContext)          private var modelContext
    @Environment(\.dismiss)              private var dismiss

    // MARK: State (lokale Kopien)

    @State private var editTitle:       String
    @State private var editText:        String
    @State private var editDate:        Date
    @State private var editStarRating:  Int
    @State private var editCategoryId:  String

    @State private var showCategoryPicker = false

    @FocusState private var focusedField: Field?

    // MARK: Private

    private enum Field: Hashable {
        case title, text
    }

    private var category: Category? {
        Category.all.first { $0.id == editCategoryId }
    }

    // MARK: Init

    /// Initialisiert die lokalen State-Kopien aus der übergebenen Activity.
    init(activity: Activity) {
        self.activity    = activity
        _editTitle       = State(initialValue: activity.title ?? "")
        _editText        = State(initialValue: activity.text ?? "")
        _editDate        = State(initialValue: activity.date)
        _editStarRating  = State(initialValue: activity.starRating)
        _editCategoryId  = State(initialValue: activity.categoryId)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Kategorie (antippbar) ────────────────────────
                    if let category {
                        Button {
                            showCategoryPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    Color(hex: category.colorHex),
                                                    lineWidth: 2)
                                        )
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: category.colorHex))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.localizedName(for: languageManager.currentLanguageCode))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "edit.category.change",
                                                defaultValue: "Kategorie ändern"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }

                    Divider().padding(.horizontal).padding(.top, 12)

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

                    // ── Sterne-Bewertung ─────────────────────────────
                    StarRatingView(rating: $editStarRating, isEditable: true)
                        .padding(.top, 12)
                }
            }
            .navigationTitle(String(localized: "edit.title", defaultValue: "Bearbeiten"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            NavigationStack {
                AddActivityCategoryScreen(
                    editBinding: Binding(
                        get: { editCategoryId },
                        set: { newId in
                            if let newId { editCategoryId = newId }
                            showCategoryPicker = false
                        }
                    ),
                    isEditMode: true
                )
                .navigationTitle(String(localized: "edit.category.title",
                                        defaultValue: "Kategorie ändern"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(String(localized: "action.cancel", defaultValue: "Abbrechen")) {
                            showCategoryPicker = false
                        }
                    }
                }
            }
        }
    }

    // MARK: Save

    private func saveChanges() {
        activity.title      = editTitle.isBlank ? nil : editTitle
        activity.text       = editText.isBlank  ? nil : editText
        activity.date       = editDate
        activity.starRating = editStarRating
        activity.categoryId = editCategoryId
        activityVM.updateActivity(activity, context: modelContext)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Edit Activity Screen") {
    let analytics      = AnalyticsManager()
    let actVM          = ActivityViewModel(analytics: analytics)
    let userSettings   = UserSettings()
    let languageManager = LanguageManager()
    let addActivityVM  = AddActivityViewModel()
    let storeKitMgr    = StoreKitManager()

    return EditActivityScreen(activity: Activity.preview)
        .environment(actVM)
        .environment(userSettings)
        .environment(languageManager)
        .environment(addActivityVM)
        .environment(storeKitMgr)
}
