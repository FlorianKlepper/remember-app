// AddActivityTextScreen.swift
// ActivityTracker2 — Remember
// Step 3 des Add-Flows: Titel, Text und Datum eingeben

import SwiftUI
import SwiftData
import PhotosUI
import ImageIO
import CoreLocation

// MARK: - AddActivityTextScreen

/// Screen 3 des Add-Flows. Bietet Titel- und Textfelder sowie eine Datumsauswahl.
/// Nach erfolgreichem Speichern wird `addActivityVM.isSaved = true` gesetzt, was
/// `AddActivityCategoryScreen` veranlasst, das Sheet zu schließen.
struct AddActivityTextScreen: View {

    // MARK: Environment

    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(ActivityViewModel.self)    private var activityVM
    @Environment(AnalyticsManager.self)     private var analyticsManager
    @Environment(LanguageManager.self)      private var languageManager
    @Environment(\.modelContext)            private var modelContext
    @Environment(\.dismiss)                 private var dismiss

    // MARK: State

    /// Fokussiertes Textfeld im Formular.
    @FocusState private var focusedField: Field?

    /// Fehlermeldung nach einem fehlgeschlagenen Speichervorgang.
    @State private var saveError: String? = nil

    /// Toast für den allerersten gespeicherten Eintrag.
    @State private var showFirstActivityToast = false

    /// Ausgewähltes Foto aus der PhotosPicker-Session.
    @State private var selectedPhoto: PhotosPickerItem? = nil

    /// Aufnahme-Datum des gewählten Fotos (aus EXIF / PHAsset).
    @State private var photoDate: Date? = nil

    /// Zeigt Alert, wenn Foto-Datum vom Aktivitätsdatum abweicht.
    @State private var showPhotoDateAlert = false

    // MARK: Private

    private enum Field: Hashable {
        case title, text
    }

    // MARK: Computed — Kategorie

    private var selectedCategory: Category? {
        guard let id = addActivityVM.selectedCategoryId else { return nil }
        return (Category.mvpCategories + Category.plusCategories)
            .first { $0.id == id }
    }

    private var categoryColor: Color {
        Color(hex: selectedCategory?.colorHex ?? "888888")
    }

    private var categoryIconName: String {
        selectedCategory?.iconName ?? "questionmark"
    }

    private var categoryName: String {
        selectedCategory?.localizedName(for: languageManager.currentLanguageCode) ?? ""
    }

    private var locationDisplayText: String {
        let poi  = addActivityVM.pendingLocationName ?? ""
        let city = addActivityVM.pendingCity ?? ""
        if !poi.isEmpty && !city.isEmpty { return "\(poi) · \(city)" }
        if !poi.isEmpty  { return poi }
        return city
    }

    private var photoPickerLabel: some View {
        VStack(spacing: 6) {
            Image(systemName: "camera.fill")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text(String(localized: "add.photo.button", defaultValue: "Foto"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
        )
    }

    // MARK: Body

    var body: some View {
        @Bindable var vm = addActivityVM

        ScrollView {
            VStack(spacing: 0) {

                // ── Header: Location + Kategorie ─────────────────────
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

                        if selectedCategory != nil {
                            HStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(categoryColor, lineWidth: 1.5)
                                        )
                                    Image(systemName: categoryIconName)
                                        .font(.system(size: 11))
                                        .foregroundStyle(categoryColor)
                                }
                                Text(categoryName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }

                        if !locationDisplayText.isEmpty {
                            Text(locationDisplayText)
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

                // ── Datum ─────────────────────────────────────────────
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

                // ── Titel ─────────────────────────────────────────────
                TextField(
                    String(localized: "add.text.title.placeholder",
                           defaultValue: "Title"),
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

                // ── Text ──────────────────────────────────────────────
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.text)
                        .font(.body)
                        .focused($focusedField, equals: .text)
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        .frame(minHeight: 100, maxHeight: 180)

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

                Divider()

                // ── Foto + Sterne nebeneinander ───────────────────────
                HStack(alignment: .top, spacing: 12) {

                    if let photoData = addActivityVM.selectedPhotoData,
                       let uiImage = UIImage(data: photoData) {

                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button {
                                addActivityVM.selectedPhotoData = nil
                                selectedPhoto = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                                    .font(.system(size: 18))
                            }
                            .offset(x: 6, y: -6)
                        }

                    } else {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            VStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "add.photo.button",
                                            defaultValue: "Photo"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 70, height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                    )
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        StarRatingView(
                            rating: Binding(
                                get: { addActivityVM.starRating },
                                set: { addActivityVM.starRating = $0 }
                            ),
                            isEditable: true
                        )
                        .fixedSize()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .fixedSize()

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .onChange(of: selectedPhoto) { _, item in
                    Task { await handlePhotoSelection(item) }
                }

                // ── Fehler ────────────────────────────────────────────
                if let error = saveError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                Spacer(minLength: 16)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle(String(localized: "add.step3.title", defaultValue: "Entry"))
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
        // ── Foto-Datum-Alert ──────────────────────────────────────
        .alert(
            String(localized: "add.photo.date.alert.title",
                   defaultValue: "Use photo date?"),
            isPresented: $showPhotoDateAlert,
            presenting: photoDate
        ) { date in
            Button(String(localized: "add.photo.date.alert.confirm",
                          defaultValue: "Yes, use this date")) {
                addActivityVM.selectedDate = date
            }
            Button(String(localized: "add.photo.date.alert.cancel",
                          defaultValue: "No, keep current"),
                   role: .cancel) {}
        } message: { date in
            Text(String(
                localized: "add.photo.date.alert.message",
                defaultValue: "Taken on \(formattedDate(date))"
            ))
        }
        // ── Erster-Moment-Sheet ───────────────────────────────────────
        .sheet(isPresented: $showFirstActivityToast) {
            VStack(spacing: 20) {

                Text("🎉")
                    .font(.system(size: 60))
                    .padding(.top, 32)

                Text(String(localized: "first.activity.title",
                            defaultValue: "Your first moment!"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(String(localized: "first.activity.body",
                            defaultValue: "You've just captured your first moment.\nYour personal world map has begun. ✨"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Divider()
                    .padding(.horizontal, 40)

                Text(String(localized: "first.activity.quote",
                            defaultValue: "Every journey begins\nwith a single step."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
                    .multilineTextAlignment(.center)

                Button {
                    showFirstActivityToast = false
                    NotificationCenter.default.post(name: .dismissAddActivity, object: nil)
                } label: {
                    Text(String(localized: "first.activity.cta",
                                defaultValue: "Let's go! 🚀"))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "#E8593C"))
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(28)
        }
    }


    // MARK: Save

    private func save() async {
        saveError = nil
        do {
            try await addActivityVM.saveActivity(
                activityViewModel: activityVM,
                analytics: analyticsManager,
                context: modelContext
            )

            // 1. Felder zurücksetzen — vor dismiss damit beim nächsten Öffnen alles leer ist
            addActivityVM.reset()

            // 2. Filter zurücksetzen
            NotificationCenter.default.post(name: .filterCleared, object: nil)

            // 3. Neue Aktivität auf Karte zeigen
            NotificationCenter.default.post(name: .activitySaved, object: nil)

            // 3. Sheet auf medium (0.45) hochfahren
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .setSheetMedium, object: nil)
            }

            // 4. Erster-Moment-Sheet (nur beim allerersten Eintrag)
            if activityVM.activities.count == 1 {
                showFirstActivityToast = true
                HapticManager.success()
            } else {
                NotificationCenter.default.post(name: .dismissAddActivity, object: nil)
            }

        } catch {
            saveError = String(
                localized: "add.save.error",
                defaultValue: "Save failed. Please try again."
            )
        }
    }

    // MARK: Helpers

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: date)
    }

    // MARK: Photo Selection

    /// Lädt das gewählte Foto, komprimiert es und liest das Aufnahmedatum aus EXIF/TIFF.
    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        guard let data = try? await item.loadTransferable(type: Data.self) else { return }

        // 1. Foto komprimieren
        if let uiImage = UIImage(data: data) {
            let compressed = uiImage.jpegData(compressionQuality: 0.7) ?? data
            await MainActor.run {
                if compressed.count > 800_000 {
                    let ratio   = 800_000.0 / Double(compressed.count)
                    let quality = 0.7 * ratio
                    addActivityVM.selectedPhotoData = uiImage.jpegData(compressionQuality: quality)
                } else {
                    addActivityVM.selectedPhotoData = compressed
                }
            }
        }

        // 2. EXIF-Datum lesen
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                as? [String: Any] else { return }

        let exifDate = (properties["{Exif}"] as? [String: Any])?["DateTimeOriginal"] as? String
        let tiffDate = (properties["{TIFF}"] as? [String: Any])?["DateTime"] as? String
        let dateString = exifDate ?? tiffDate

        guard let dateString else {
            print("[Photo] Kein EXIF/TIFF Datum gefunden")
            return
        }
        print("[Photo] EXIF Datum String: \(dateString)")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let photoDate = formatter.date(from: dateString) else {
            print("[Photo] Datum konnte nicht geparst werden")
            return
        }
        print("[Photo] EXIF Datum: \(photoDate)")

        await MainActor.run {
            self.photoDate = photoDate
            let isSameDay = Calendar.current.isDate(
                photoDate, inSameDayAs: addActivityVM.selectedDate)
            print("[Photo] Gleicher Tag: \(isSameDay)")
            if !isSameDay {
                showPhotoDateAlert = true
            }
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

