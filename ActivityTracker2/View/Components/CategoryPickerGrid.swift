// CategoryPickerGrid.swift
// ActivityTracker2 — Remember
// Kategorie-Auswahl mit gemischten MVP + Plus Clustern

import SwiftUI

// MARK: - CategoryPickerGrid

/// Scrollbare Kategorie-Auswahl mit 8 Clustern.
/// Jeder Cluster enthält MVP- und Plus-Kategorien gemischt.
/// Plus-Kategorien erscheinen einzeln gesperrt wenn kein Plus-Abo aktiv.
struct CategoryPickerGrid: View {

    // MARK: Parameter

    @Binding var selectedCategoryId: String?
    let userSettings: UserSettings
    let language: String

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(StoreKitManager.self)    private var storeKitManager

    // MARK: State

    @State private var showPlusScreen = false

    // MARK: Private

    private var isPlusUser: Bool {
        storeKitManager.isPlusActive || userSettings.subscriptionStatus.isPremium
    }

    // MARK: Computed Category Groups

    private var usedCategories: [Category] {
        let usedIds = Set(activityVM.activities.map { $0.categoryId })
        return Category.all.filter { usedIds.contains($0.id) }
    }

    private var journalCategories: [Category] {
        Category.mvpCategories.filter { $0.id == "journal" }
    }

    private var foodAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter {
            ["restaurant", "cafe", "bar", "wine_tasting"].contains($0.id)
        }
        let plus = Category.plusCategories.filter { $0.colorHex == "#BA7517" }
        return mvp + plus
    }

    private var sportAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter {
            ["running", "hiking", "cycling", "skiing", "fitness", "football",
             "gym", "climbing", "swimming", "yoga", "tennis", "golf", "dancing"].contains($0.id)
        }
        let plus = Category.plusCategories.filter { $0.colorHex == "#D85A30" }
        return mvp + plus
    }

    private var outdoorAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter {
            ["park", "beach", "picnic", "campsite", "viewpoint"].contains($0.id)
        }
        let plus = Category.plusCategories.filter { $0.colorHex == "#1D9E75" }
        return mvp + plus
    }

    private var kulturAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter {
            ["museum", "cinema", "concert", "theater", "festival"].contains($0.id)
        }
        let plus = Category.plusCategories.filter { $0.colorHex == "#7F77DD" }
        return mvp + plus
    }

    private var kreativAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter { $0.id == "photography" }
        let plus = Category.plusCategories.filter { $0.colorHex == "#378ADD" }
        return mvp + plus
    }

    private var lifestyleAllCategories: [Category] {
        let mvp = Category.mvpCategories.filter { $0.id == "travel" }
        let plus = Category.plusCategories.filter { $0.colorHex == "#D4537E" }
        return mvp + plus
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                if !usedCategories.isEmpty {
                    categorySection(
                        title: String(localized: "category.section.used",
                                      defaultValue: "Verwendete Kategorien"),
                        subtitle: nil,
                        categories: usedCategories
                    )
                }

                categorySection(
                    title: String(localized: "category.section.journal",
                                  defaultValue: "Tagebuch"),
                    subtitle: String(localized: "category.section.journal.subtitle",
                                     defaultValue: "Persönliche Einträge"),
                    categories: journalCategories
                )

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
                                     defaultValue: "Musik, Kunst & Entertainment"),
                    categories: kulturAllCategories
                )

                categorySection(
                    title: String(localized: "category.section.kreativ",
                                  defaultValue: "Kreativ"),
                    subtitle: String(localized: "category.section.kreativ.subtitle",
                                     defaultValue: "Fotografie & mehr"),
                    categories: kreativAllCategories
                )

                categorySection(
                    title: String(localized: "category.section.lifestyle",
                                  defaultValue: "Lifestyle"),
                    subtitle: String(localized: "category.section.lifestyle.subtitle",
                                     defaultValue: "Reisen, Shopping & Wellness"),
                    categories: lifestyleAllCategories
                )

                if !isPlusUser {
                    plusCtaSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showPlusScreen) {
            PlusScreen()
        }
    }

    // MARK: Section Helper

    @ViewBuilder
    private func categorySection(
        title: String,
        subtitle: String?,
        categories: [Category]
    ) -> some View {
        if !categories.isEmpty {
            VStack(alignment: .leading, spacing: 12) {

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 12
                ) {
                    ForEach(categories) { category in
                        categoryCell(category: category)
                    }
                }
            }
        }
    }

    // MARK: Cell Helper

    @ViewBuilder
    private func categoryCell(category: Category) -> some View {
        let locked     = category.isPlusOnly && !isPlusUser
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

                    // Lock-Badge für gesperrte Plus-Kategorien
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

    // MARK: Plus CTA

    @ViewBuilder
    private var plusCtaSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "#FFD700"))

            Text(String(localized: "plus.cta.title", defaultValue: "Remember Plus"))
                .font(.headline)

            Text(String(localized: "plus.cta.subtitle",
                        defaultValue: "Schalte 70 weitere Kategorien und unbegrenzte Aktivitäten frei."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPlusScreen = true
            } label: {
                Text(String(localized: "plus.cta.button", defaultValue: "Plus freischalten"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color(hex: "#E8593C")))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview("Category Picker Grid — Free") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings        = UserSettings()
    let analytics       = AnalyticsManager()
    let activityVM      = ActivityViewModel(analytics: analytics)
    let storeKitManager = StoreKitManager()
    activityVM.activities = Activity.samples

    return CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
    .environment(activityVM)
    .environment(storeKitManager)
}

#Preview("Category Picker Grid — Plus") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings        = UserSettings()
    let analytics       = AnalyticsManager()
    let activityVM      = ActivityViewModel(analytics: analytics)
    let storeKitManager = StoreKitManager()
    settings.subscriptionStatus = .plus
    activityVM.activities = Activity.samples

    return CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
    .environment(activityVM)
    .environment(storeKitManager)
}
