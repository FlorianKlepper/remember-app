// CategoryPickerGrid.swift
// ActivityTracker2 — Remember
// Kategorie-Auswahl-Grid für AddActivityCategoryScreen

import SwiftUI

// MARK: - CategoryPickerGrid

/// 5-spaltiges LazyVGrid zur Kategorie-Auswahl.
/// MVP-Kategorien und Plus-Kategorien werden mit Abschnitt-Überschrift getrennt.
/// Plus-Kategorien für Free-User erscheinen gedimmt mit `PlusBadge`-Overlay.
struct CategoryPickerGrid: View {

    // MARK: Parameter

    @Binding var selectedCategoryId: String?
    let userSettings: UserSettings
    let language: String

    // MARK: Private

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    private var isPremium: Bool {
        userSettings.subscriptionStatus.isPremium
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── MVP Kategorien ────────────────────────────────
                categorySection(
                    titleKey: "category.section.free",
                    categories: Category.mvpCategories,
                    isLocked: false
                )

                // ── Plus Kategorien ───────────────────────────────
                categorySection(
                    titleKey: "category.section.plus",
                    categories: Category.plusCategories,
                    isLocked: !isPremium
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: Private Views

    @ViewBuilder
    private func categorySection(
        titleKey: LocalizedStringKey,
        categories: [Category],
        isLocked: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titleKey)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(categories) { category in
                    categoryCell(category: category, isLocked: isLocked)
                }
            }
        }
    }

    @ViewBuilder
    private func categoryCell(category: Category, isLocked: Bool) -> some View {
        let isSelected = selectedCategoryId == category.id
        let categoryColor = Color(hex: category.colorHex)

        Button {
            if !isLocked {
                selectedCategoryId = category.id
                HapticManager.selectionChanged()
            }
        } label: {
            VStack(spacing: 6) {
                CategoryIconView(categoryId: category.id, size: 44)
                    .overlay(alignment: .topTrailing) {
                        if isLocked {
                            PlusBadge()
                                .offset(x: 4, y: -4)
                        }
                    }

                Text(category.localizedName(for: language))
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(isSelected ? categoryColor : .primary)
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? categoryColor : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.5 : 1.0)
    }
}

// MARK: - Preview

#Preview("Category Picker Grid") {
    @Previewable @State var selectedId: String? = "hiking"
    let settings = UserSettings()

    CategoryPickerGrid(
        selectedCategoryId: $selectedId,
        userSettings: settings,
        language: "de"
    )
}
