// CategoryPickerGrid.swift
// ActivityTracker2 — Remember
// Kategorie-Auswahl mit strukturierten Sections und Labels

import SwiftUI

// MARK: - CategoryPickerGrid

/// Scrollbare Kategorie-Auswahl mit Sections (Verwendet, Outdoor, Sport, …).
/// 4-spaltiges Grid — jede Zelle zeigt Icon + Label.
/// Plus-Kategorien erscheinen gesperrt für Free-User.
struct CategoryPickerGrid: View {

    // MARK: Parameter

    @Binding var selectedCategoryId: String?
    let userSettings: UserSettings
    let language: String

    // MARK: Environment

    @Environment(ActivityViewModel.self) private var activityVM

    // MARK: Private

    private var isPremium: Bool { userSettings.subscriptionStatus.isPremium }

    // MARK: Computed Category Groups

    /// Kategorien die bereits in mindestens einer Aktivität verwendet wurden.
    private var usedCategories: [Category] {
        let usedIds = Set(activityVM.activities.map { $0.categoryId })
        return Category.mvpCategories.filter { usedIds.contains($0.id) }
    }

    private var outdoorCategories: [Category] {
        Category.mvpCategories.filter {
            ["park", "beach", "picnic", "campsite", "viewpoint"].contains($0.id)
        }
    }

    private var sportCategories: [Category] {
        Category.mvpCategories.filter {
            ["running", "hiking", "cycling", "skiing", "fitness", "football",
             "gym", "climbing", "swimming", "yoga", "tennis", "golf", "dancing"].contains($0.id)
        }
    }

    private var foodCategories: [Category] {
        Category.mvpCategories.filter {
            ["restaurant", "cafe", "bar", "wine_tasting"].contains($0.id)
        }
    }

    private var kulturCategories: [Category] {
        Category.mvpCategories.filter {
            ["museum", "cinema", "concert", "theater", "festival"].contains($0.id)
        }
    }

    private var kreativCategories: [Category] {
        Category.mvpCategories.filter {
            ["journal", "photography"].contains($0.id)
        }
    }

    private var lifestyleCategories: [Category] {
        Category.mvpCategories.filter {
            ["travel"].contains($0.id)
        }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                if !usedCategories.isEmpty {
                    categorySection(
                        title: String(localized: "category.section.used",
                                     defaultValue: "Verwendet"),
                        subtitle: nil,
                        categories: usedCategories
                    )
                }

                categorySection(
                    title: String(localized: "category.section.outdoor",
                                  defaultValue: "Outdoor"),
                    subtitle: String(localized: "category.section.outdoor.subtitle",
                                     defaultValue: "Natur & Abenteuer"),
                    categories: outdoorCategories
                )

                categorySection(
                    title: String(localized: "category.section.sport",
                                  defaultValue: "Sport"),
                    subtitle: String(localized: "category.section.sport.subtitle",
                                     defaultValue: "Aktivitäten & Fitness"),
                    categories: sportCategories
                )

                categorySection(
                    title: String(localized: "category.section.food",
                                  defaultValue: "Essen & Trinken"),
                    subtitle: String(localized: "category.section.food.subtitle",
                                     defaultValue: "Restaurants, Cafés & Bars"),
                    categories: foodCategories
                )

                categorySection(
                    title: String(localized: "category.section.kultur",
                                  defaultValue: "Kultur"),
                    subtitle: String(localized: "category.section.kultur.subtitle",
                                     defaultValue: "Musik, Kunst & Entertainment"),
                    categories: kulturCategories
                )

                categorySection(
                    title: String(localized: "category.section.kreativ",
                                  defaultValue: "Kreativ"),
                    subtitle: String(localized: "category.section.kreativ.subtitle",
                                     defaultValue: "Kunst, Fotografie & mehr"),
                    categories: kreativCategories
                )

                categorySection(
                    title: String(localized: "category.section.lifestyle",
                                  defaultValue: "Lifestyle"),
                    subtitle: String(localized: "category.section.lifestyle.subtitle",
                                     defaultValue: "Reisen, Shopping & Wellness"),
                    categories: lifestyleCategories
                )

                if !isPremium {
                    categorySection(
                        title: String(localized: "category.section.plus",
                                      defaultValue: "Plus"),
                        subtitle: String(localized: "category.section.plus.subtitle",
                                         defaultValue: "Weitere Kategorien freischalten"),
                        categories: Category.plusCategories,
                        isLocked: true
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: Section Helper

    @ViewBuilder
    private func categorySection(
        title: String,
        subtitle: String?,
        categories: [Category],
        isLocked: Bool = false
    ) -> some View {
        if !categories.isEmpty {
            VStack(alignment: .leading, spacing: 12) {

                // Section Header
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

                // 4-spaltiges Grid
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 12
                ) {
                    ForEach(categories) { category in
                        categoryCell(category: category, isLocked: isLocked)
                    }
                }
            }
        }
    }

    // MARK: Cell Helper

    @ViewBuilder
    private func categoryCell(category: Category, isLocked: Bool = false) -> some View {
        let isSelected = selectedCategoryId == category.id
        let color      = Color(hex: category.colorHex)
        let name       = language == "de" ? category.nameDe : category.nameEn

        Button {
            if !isLocked {
                selectedCategoryId = category.id
                HapticManager.selectionChanged()
            }
        } label: {
            VStack(spacing: 6) {

                // ── Icon (Map-Pin-Stil: weißer Kreis + farbiger Rand) ──
                ZStack {
                    // Weißer Kreis mit farbigem Rand
                    Circle()
                        .fill(.white)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? color : color.opacity(0.4),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                        )
                        .shadow(
                            color: isSelected ? color.opacity(0.3) : .black.opacity(0.06),
                            radius: isSelected ? 6 : 2,
                            x: 0,
                            y: isSelected ? 3 : 1
                        )

                    // Icon in Kategorie-Farbe
                    Image(systemName: category.iconName)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? color : color.opacity(0.7))

                    // Ausgewählt: Checkmark-Badge
                    if isSelected {
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

                    // Plus-Lock-Overlay
                    if isLocked {
                        Circle()
                            .fill(.black.opacity(0.35))
                            .frame(width: 52, height: 52)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                }

                // ── Label ────────────────────────────────────────────
                Text(name)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? color : Color(.secondaryLabel))
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

#Preview("Category Picker Grid") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings   = UserSettings()
    let analytics  = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    activityVM.activities = Activity.samples

    return CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
    .environment(activityVM)
}
