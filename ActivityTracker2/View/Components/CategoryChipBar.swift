// CategoryChipBar.swift
// ActivityTracker2 — Remember
// Horizontale scrollbare Kategorie-Chips für Map und Liste

import SwiftUI

// MARK: - CategoryChipBar

/// Horizontale, scrollbare Chip-Leiste für den aktiven Kategorie-Filter.
/// Erster Chip: "Alle" — setzt Filter zurück.
/// Folgende Chips: genutzte Kategorien, sortiert nach Anzahl absteigend.
/// Wird bei Swipe-Geste in der Liste automatisch nachgeführt.
struct CategoryChipBar: View {

    // MARK: Parameter

    var filterVM: FilterViewModel
    let activities: [Activity]
    let language: String

    // MARK: Private

    private var sortedCategories: [Category] {
        filterVM.sortedUsedCategories(from: activities)
    }

    // MARK: Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                    // ── "Alle"-Chip ───────────────────────────────
                    allChip
                        .id("all")

                    // ── Kategorie-Chips ───────────────────────────
                    ForEach(sortedCategories) { category in
                        categoryChip(category)
                            .id(category.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .onChange(of: filterVM.selectedCategoryId) { _, newId in
                withAnimation {
                    proxy.scrollTo(newId ?? "all", anchor: .center)
                }
            }
        }
    }

    // MARK: Private Views

    private var allChip: some View {
        let isActive = !filterVM.isFilterActive
        return Button {
            filterVM.clearFilter()
            HapticManager.selectionChanged()
        } label: {
            Text("filter.all")
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    isActive ? Color.primary : Color(.systemGray6),
                    in: Capsule()
                )
                .foregroundStyle(isActive ? Color(.systemBackground) : .primary)
        }
        .buttonStyle(.plain)
    }

    private func categoryChip(_ category: Category) -> some View {
        let isActive = filterVM.selectedCategoryId == category.id
        let categoryColor = Color(hex: category.colorHex)

        return Button {
            filterVM.setFilter(categoryId: category.id)
            HapticManager.selectionChanged()
        } label: {
            HStack(spacing: 4) {
                CategoryIconView(categoryId: category.id, size: 16)
                let count = activities.filter { $0.categoryId == category.id }.count
                Text("\(category.localizedName(for: language)) (\(count))")
                    .font(.caption)
                    .fontWeight(isActive ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isActive ? categoryColor : Color(.systemGray6),
                in: Capsule()
            )
            .foregroundStyle(isActive ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Category Chip Bar") {
    let filterVM = FilterViewModel()
    let activities = Activity.samples

    VStack(spacing: 20) {
        Text("Kein Filter aktiv")
            .font(.caption)
            .foregroundStyle(.secondary)
        CategoryChipBar(filterVM: filterVM, activities: activities, language: "de")

        Divider()

        Text("Filter: Wandern aktiv")
            .font(.caption)
            .foregroundStyle(.secondary)
        CategoryChipBar(filterVM: {
            let vm = FilterViewModel()
            vm.setFilter(categoryId: "hiking")
            return vm
        }(), activities: activities, language: "de")
    }
    .padding(.vertical)
    .background(Color(.systemBackground))
}
