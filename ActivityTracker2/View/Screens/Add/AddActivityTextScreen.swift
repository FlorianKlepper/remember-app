// AddActivityTextScreen.swift
// ActivityTracker2 — Remember
// Step 3 des Add-Flows: Titel, Text und Datum eingeben

import SwiftUI
import SwiftData
import CoreLocation

// MARK: - AddActivityTextScreen

/// Screen 3 des Add-Flows. Bietet Titel- und Textfelder sowie eine Datumsauswahl.
/// Nach erfolgreichem Speichern wird `addActivityVM.isSaved = true` gesetzt, was
/// `AddActivityCategoryScreen` veranlasst, das Sheet zu schließen.
struct AddActivityTextScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(ActivityViewModel.self)    private var activityVM
    @Environment(LanguageManager.self)      private var languageManager
    @Environment(\.modelContext)            private var modelContext

    // MARK: State

    /// Fokussiertes Textfeld im Formular.
    @FocusState private var focusedField: Field?

    /// Fehlermeldung nach einem fehlgeschlagenen Speichervorgang.
    @State private var saveError: String? = nil

    /// Toast für den allerersten gespeicherten Eintrag.
    @State private var showFirstActivityToast = false

    // MARK: Private

    private enum Field: Hashable {
        case title, text
    }

    // MARK: Body

    var body: some View {
        @Bindable var vm = addActivityVM

        VStack(spacing: 0) {

            // ── Header: Location + Kategorie ─────────────────────────
            HStack(spacing: 12) {

                if let coord = addActivityVM.pendingCoordinate {
                    MiniMapView(
                        coordinate: coord,
                        categoryId: addActivityVM.selectedCategoryId ?? ""
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.33, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 4) {

                    if let categoryId = addActivityVM.selectedCategoryId,
                       let category = (Category.mvpCategories + Category.plusCategories)
                           .first(where: { $0.id == categoryId }) {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                Color(hex: category.colorHex),
                                                lineWidth: 1.5
                                            )
                                    )
                                Image(systemName: category.iconName)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: category.colorHex))
                            }
                            Text(category.localizedName(
                                for: languageManager.currentLanguageCode))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }

                    if let city = addActivityVM.pendingCity {
                        Text(city)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let name = addActivityVM.pendingLocationName, !name.isBlank {
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))

            Divider()

            // ── Datum ─────────────────────────────────────────────────
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                DatePicker(
                    "",
                    selection: $vm.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // ── Titel ─────────────────────────────────────────────────
            TextField(
                String(localized: "add.text.title.placeholder",
                       defaultValue: "Titel"),
                text: $vm.title
            )
            .font(.body)
            .fontWeight(.medium)
            .focused($focusedField, equals: .title)
            .submitLabel(.return)
            .onSubmit { focusedField = .text }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // ── Text ──────────────────────────────────────────────────
            ZStack(alignment: .topLeading) {
                TextEditor(text: $vm.text)
                    .font(.body)
                    .focused($focusedField, equals: .text)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                    .frame(minHeight: 150)

                if vm.text.isEmpty {
                    Text(String(localized: "add.text.body.placeholder",
                                defaultValue: "Text"))
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
            }

            Spacer()

            // ── Fehler ────────────────────────────────────────────────
            if let error = saveError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
            }

            Divider()

            // ── Sterne ────────────────────────────────────────────────
            StarRatingView(
                rating: Binding(
                    get: { addActivityVM.starRating },
                    set: { addActivityVM.starRating = $0 }
                ),
                isEditable: true
            )
            .padding(.vertical, 8)
            .padding(.bottom,
                UIApplication.shared
                    .connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows.first?.safeAreaInsets.bottom ?? 0
            )
        }
        .navigationTitle(String(localized: "add.step3.title", defaultValue: "Eintrag"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if addActivityVM.isLoading {
                    ProgressView()
                } else {
                    Button {
                        Task { await save() }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                }
            }
        }
        .onAppear {
            focusedField = .title
        }
        // ── Erster-Moment-Toast ───────────────────────────────────────
        .overlay(alignment: .top) {
            if showFirstActivityToast {
                HStack(spacing: 8) {
                    Text("Dein erster Moment 🎉")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(hex: "#E8593C"))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showFirstActivityToast)
    }


    // MARK: Save

    private func save() async {
        saveError = nil
        do {
            try await addActivityVM.saveActivity(
                activityViewModel: activityVM,
                context: modelContext
            )

            // 1. Filter zurücksetzen
            NotificationCenter.default.post(name: .filterCleared, object: nil)

            // 2. Neue Aktivität auf Karte zeigen
            NotificationCenter.default.post(name: .activitySaved, object: nil)

            // 3. Sheet auf medium (0.45) hochfahren
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .setSheetMedium, object: nil)
            }

            // 4. Erster-Moment-Toast (nur beim allerersten Eintrag)
            if activityVM.activities.count == 1 {
                withAnimation { showFirstActivityToast = true }
                HapticManager.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showFirstActivityToast = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        addActivityVM.isSaved = true
                    }
                }
            } else {
                addActivityVM.isSaved = true
            }

        } catch {
            saveError = String(
                localized: "add.save.error",
                defaultValue: "Speichern fehlgeschlagen. Bitte erneut versuchen."
            )
        }
    }
}

// MARK: - Preview

#Preview("Add — Step 3: Text") {
    let analytics = AnalyticsManager()
    let addVM     = AddActivityViewModel()
    let actVM     = ActivityViewModel(analytics: analytics)
    let langMgr   = LanguageManager()

    addVM.selectedCategoryId  = "hiking"
    addVM.pendingLocationName = "München, Bayern"
    addVM.pendingCity         = "München"
    addVM.pendingCoordinate   = .init(latitude: 48.1351, longitude: 11.5820)

    return NavigationStack {
        AddActivityTextScreen()
    }
    .environment(addVM)
    .environment(actVM)
    .environment(langMgr)
}

