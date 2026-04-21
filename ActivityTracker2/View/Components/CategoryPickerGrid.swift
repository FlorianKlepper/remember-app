// CategoryPickerGrid.swift
// ActivityTracker2 — Remember
// Kategorie-Auswahl mit Clustern — Plus/Free unterschiedliches Layout

import SwiftUI

// MARK: - CategoryPickerGrid

/// Scrollbare Kategorie-Auswahl.
/// Plus-User: alle Cluster gemischt (MVP + Plus).
/// Free-User: MVP-Cluster einzeln + alle Plus-Kategorien gesperrt am Ende.
struct CategoryPickerGrid: View {

    // MARK: Parameter

    @Binding var selectedCategoryId: String?
    let userSettings: UserSettings
    let language: String

    // MARK: Environment

    @Environment(ActivityViewModel.self)    private var activityVM
    @Environment(AddActivityViewModel.self) private var addActivityVM
    @Environment(StoreKitManager.self)      private var storeKitManager

    // MARK: State

    @State private var showPlusScreen  = false
    @State private var showHomePrompt  = false

    // MARK: Private

    private var isPlusUser: Bool {
        storeKitManager.isPlusActive ||
        userSettings.subscriptionStatus == .plus
    }

    // MARK: Computed — Gemeinsam

    /// IDs aller bereits verwendeten Kategorien — werden aus Clustern herausgefiltert.
    private var usedCategoryIds: Set<String> {
        Set(activityVM.activities.map { $0.categoryId })
    }

    private var usedCategoriesWithoutJournal: [Category] {
        Category.all.filter {
            usedCategoryIds.contains($0.id) && $0.id != "journal"
        }
    }

    private var journalCategories: [Category] {
        Category.mvpCategories.filter {
            $0.id == "journal" && !usedCategoryIds.contains($0.id)
        }
    }

    // MARK: Tagebuch Section (immer sichtbar — immer beide Buttons)

    private var journalIconName: String {
        Category.mvpCategories.first { $0.id == "journal" }?.iconName ?? "book.fill"
    }

    private var journalColor: Color {
        Color(hex: Category.mvpCategories.first { $0.id == "journal" }?.colorHex ?? "#378ADD")
    }

    @ViewBuilder
    private var tagebuchSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.journalSectionTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(L10n.journalSectionSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 12
            ) {

                // ── Journal Home ───────────────────────────────────────
                Button {
                    if userSettings.hasHomeLocation {
                        addActivityVM.useHomeLocation(from: userSettings)
                        addActivityVM.skipLocationScreen = true
                        selectedCategoryId = "journal"
                        HapticManager.selectionChanged()
                    } else {
                        showHomePrompt = true
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Circle().strokeBorder(journalColor, lineWidth: 2)
                                )
                            Image(systemName: journalIconName)
                                .font(.system(size: 22))
                                .foregroundStyle(journalColor)
                        }
                        Text(L10n.journalHome)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)

                // ── Journal On the Road ────────────────────────────────
                Button {
                    addActivityVM.skipLocationScreen = false
                    selectedCategoryId = "journal"
                    HapticManager.selectionChanged()
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Circle().strokeBorder(journalColor, lineWidth: 2)
                                )
                            Image(systemName: journalIconName)
                                .font(.system(size: 22))
                                .foregroundStyle(journalColor)
                        }
                        Text(L10n.journalOnTheRoad)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)

                // Leere Zellen für Ausrichtung
                Color.clear
                Color.clear
            }
        }
    }

    // MARK: Computed — Plus (MVP + Plus gemischt, ohne bereits verwendete)

    private var foodAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            ["restaurant", "cafe", "bar", "wine_tasting"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#BA7517" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    private var sportAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            ["running", "hiking", "cycling", "skiing", "fitness", "football",
             "climbing", "swimming", "yoga", "tennis", "golf", "dancing"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#D85A30" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    private var outdoorAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            ["park", "beach", "picnic", "campsite", "viewpoint"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#1D9E75" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    private var kulturAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            ["museum", "cinema", "concert", "theater", "festival"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#7F77DD" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    private var kreativAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            $0.id == "photography" && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#378ADD" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    private var lifestyleAllCategories: [Category] {
        let mvp  = Category.mvpCategories.filter {
            $0.id == "travel" && !usedCategoryIds.contains($0.id)
        }
        let plus = Category.plusCategories.filter {
            $0.colorHex == "#D4537E" && !usedCategoryIds.contains($0.id)
        }
        return mvp + plus
    }

    // MARK: Computed — Free (nur MVP, ohne bereits verwendete)

    private var foodMVPCategories: [Category] {
        Category.mvpCategories.filter {
            ["restaurant", "cafe", "bar", "wine_tasting"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
    }

    private var sportMVPCategories: [Category] {
        Category.mvpCategories.filter {
            ["running", "hiking", "cycling", "skiing", "fitness", "football",
             "climbing", "swimming", "yoga", "tennis", "golf", "dancing"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
    }

    private var outdoorMVPCategories: [Category] {
        Category.mvpCategories.filter {
            ["park", "beach", "picnic", "campsite", "viewpoint"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
    }

    private var kulturMVPCategories: [Category] {
        Category.mvpCategories.filter {
            ["museum", "cinema", "concert", "theater", "festival"].contains($0.id)
            && !usedCategoryIds.contains($0.id)
        }
    }

    private var kreativMVPCategories: [Category] {
        Category.mvpCategories.filter {
            $0.id == "photography" && !usedCategoryIds.contains($0.id)
        }
    }

    private var lifestyleMVPCategories: [Category] {
        Category.mvpCategories.filter {
            $0.id == "travel" && !usedCategoryIds.contains($0.id)
        }
    }

    /// Alle Plus-Kategorien (ohne bereits verwendete), sortiert nach Farbe.
    private var allPlusCategories: [Category] {
        Category.plusCategories
            .filter { !usedCategoryIds.contains($0.id) }
            .sorted { $0.colorHex < $1.colorHex }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── 1. Tagebuch (immer zuerst) ───────────────────────
                tagebuchSection

                // ── 2. Verwendete Kategorien (ohne Tagebuch) ─────────
                if !usedCategoriesWithoutJournal.isEmpty {
                    categorySection(
                        title: L10n.categoryUsed,
                        categories: usedCategoriesWithoutJournal
                    )
                }

                if isPlusUser {

                    // ── PLUS: alle Cluster gemischt MVP + Plus ───────

                    categorySection(
                        title: String(localized: "category.section.food",
                                      defaultValue: "Essen & Trinken"),
                        subtitle: String(localized: "category.section.food.subtitle",
                                         defaultValue: "Restaurants, Cafés & Bars"),
                        categories: foodAllCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.sport",
                                      defaultValue: "Sport"),
                        subtitle: String(localized: "category.section.sport.subtitle",
                                         defaultValue: "Aktivitäten & Fitness"),
                        categories: sportAllCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.outdoor",
                                      defaultValue: "Outdoor"),
                        subtitle: String(localized: "category.section.outdoor.subtitle",
                                         defaultValue: "Natur & Abenteuer"),
                        categories: outdoorAllCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.kultur",
                                      defaultValue: "Kultur"),
                        subtitle: String(localized: "category.section.kultur.subtitle",
                                         defaultValue: "Musik, Kunst & mehr"),
                        categories: kulturAllCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.kreativ",
                                      defaultValue: "Kreativ"),
                        subtitle: String(localized: "category.section.kreativ.subtitle",
                                         defaultValue: "Fotografie & Kunst"),
                        categories: kreativAllCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.lifestyle",
                                      defaultValue: "Lifestyle"),
                        subtitle: String(localized: "category.section.lifestyle.subtitle",
                                         defaultValue: "Reisen & Wellness"),
                        categories: lifestyleAllCategories
                    )

                } else {

                    // ── FREE: nur MVP-Cluster + gesperrte Plus-Section ─

                    categorySection(
                        title: String(localized: "category.section.food",
                                      defaultValue: "Essen & Trinken"),
                        subtitle: String(localized: "category.section.food.subtitle",
                                         defaultValue: "Restaurants, Cafés & Bars"),
                        categories: foodMVPCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.sport",
                                      defaultValue: "Sport"),
                        subtitle: String(localized: "category.section.sport.subtitle",
                                         defaultValue: "Aktivitäten & Fitness"),
                        categories: sportMVPCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.outdoor",
                                      defaultValue: "Outdoor"),
                        subtitle: String(localized: "category.section.outdoor.subtitle",
                                         defaultValue: "Natur & Abenteuer"),
                        categories: outdoorMVPCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.kultur",
                                      defaultValue: "Kultur"),
                        subtitle: String(localized: "category.section.kultur.subtitle",
                                         defaultValue: "Musik, Kunst & mehr"),
                        categories: kulturMVPCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.kreativ",
                                      defaultValue: "Kreativ"),
                        subtitle: String(localized: "category.section.kreativ.subtitle",
                                         defaultValue: "Fotografie & Kunst"),
                        categories: kreativMVPCategories
                    )

                    categorySection(
                        title: String(localized: "category.section.lifestyle",
                                      defaultValue: "Lifestyle"),
                        subtitle: String(localized: "category.section.lifestyle.subtitle",
                                         defaultValue: "Reisen & Wellness"),
                        categories: lifestyleMVPCategories
                    )

                    // Alle Plus-Kategorien gesperrt ganz unten
                    categorySection(
                        title: String(localized: "category.section.plus",
                                      defaultValue: "Plus Kategorien"),
                        subtitle: String(localized: "category.section.plus.subtitle",
                                         defaultValue: "Mit Remember Plus freischalten"),
                        categories: allPlusCategories,
                        isLocked: true,
                        showPlusCTA: true
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showPlusScreen) {
            PlusScreen(source: "category_locked")
        }
        .sheet(isPresented: $showHomePrompt) {
            HomeLocationSheet(isShowing: $showHomePrompt)
        }
    }

    // MARK: Section Helper

    @ViewBuilder
    private func categorySection(
        title: String,
        subtitle: String? = nil,
        categories: [Category],
        isLocked: Bool = false,
        showPlusCTA: Bool = false
    ) -> some View {
        if !categories.isEmpty {
            VStack(alignment: .leading, spacing: 12) {

                // Header
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if isLocked {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#FFD700"))
                        }
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Grid
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 12
                ) {
                    ForEach(categories) { category in
                        categoryCell(category: category, isLocked: isLocked)
                    }
                }

                // Plus CTA Button
                if showPlusCTA {
                    Button {
                        showPlusScreen = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color(hex: "#FFD700"))
                            Text(String(localized: "category.plus.cta.button",
                                        defaultValue: "Plus freischalten"))
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#E8593C"))
                        )
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    // MARK: Cell Helper

    @ViewBuilder
    private func categoryCell(category: Category, isLocked: Bool = false) -> some View {
        let locked     = isLocked || (category.isPlusOnly && !isPlusUser)
        let isSelected = selectedCategoryId == category.id
        let color      = Color(hex: category.colorHex)
        let name       = category.localizedName(for: language)

        Button {
            if locked {
                showPlusScreen = true
            } else {
                selectedCategoryId = category.id
                HapticManager.selectionChanged()
            }
        } label: {
            VStack(spacing: 6) {

                ZStack {
                    Circle()
                        .fill(locked ? Color(.systemGray6) : .white)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    locked
                                        ? Color(.systemGray4)
                                        : (isSelected ? color : color.opacity(0.4)),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                        )
                        .shadow(
                            color: locked
                                ? .clear
                                : (isSelected ? color.opacity(0.3) : .black.opacity(0.06)),
                            radius: isSelected ? 6 : 2,
                            x: 0,
                            y: isSelected ? 3 : 1
                        )

                    Image(systemName: category.iconName)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            locked
                                ? Color(.systemGray3)
                                : (isSelected ? color : color.opacity(0.7))
                        )

                    // Lock-Badge
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Circle().fill(Color(.systemGray3)))
                            .offset(x: 18, y: -18)
                    }

                    // Checkmark-Badge wenn ausgewählt
                    if isSelected && !locked {
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }

                Text(name)
                    .font(.system(size: 10))
                    .foregroundStyle(
                        locked
                            ? Color(.systemGray3)
                            : (isSelected ? color : Color(.secondaryLabel))
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: 60)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Preview

#Preview("Category Picker Grid — Free") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings        = UserSettings()
    let analytics       = AnalyticsManager()
    let activityVM      = ActivityViewModel(analytics: analytics)
    let addActivityVM   = AddActivityViewModel()
    let storeKitManager = StoreKitManager()
    activityVM.activities = Activity.samples

    return CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
    .environment(activityVM)
    .environment(addActivityVM)
    .environment(storeKitManager)
}

#Preview("Category Picker Grid — Plus") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings        = UserSettings()
    let analytics       = AnalyticsManager()
    let activityVM      = ActivityViewModel(analytics: analytics)
    let addActivityVM   = AddActivityViewModel()
    let storeKitManager = StoreKitManager()
    settings.subscriptionStatus = .plus
    activityVM.activities = Activity.samples

    return CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
    .environment(activityVM)
    .environment(addActivityVM)
    .environment(storeKitManager)
}
