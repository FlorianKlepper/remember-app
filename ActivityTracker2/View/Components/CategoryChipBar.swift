// CategoryChipBar.swift
// ActivityTracker2 — Remember
// Horizontale Chip-Leiste — freies Scrollen ohne Snapping

import SwiftUI

// MARK: - CategoryChipBar

/// Horizontale Chip-Leiste ohne ChipItem-Struct.
/// Tap auf Chip → Filter setzen, Map + Liste aktualisieren.
struct CategoryChipBar: View {

    var filterVM: FilterViewModel
    var activities: [Activity]
    var language: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                // "Alle" Chip
                allChip

                // Kategorie Chips
                ForEach(usedCategories, id: \.id) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
    }

    // MARK: Alle Chip

    @ViewBuilder
    private var allChip: some View {
        let isSelected = filterVM.selectedCategoryId == nil
        Button {
            filterVM.clearFilter()
            HapticManager.selectionChanged()
        } label: {
            Text(LocalizedStringKey("filter.all"))
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color(.systemBackground) : Color(.secondaryLabel))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    ZStack {
                        Capsule().fill(isSelected ? Color(.label) : Color(.systemGray6))
                        Capsule().strokeBorder(isSelected ? Color(.label) : Color.clear, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: Kategorie Chip

    @ViewBuilder
    private func categoryChip(_ category: Category) -> some View {
        let isSelected = filterVM.selectedCategoryId == category.id
        let count = activities.filter { $0.categoryId == category.id }.count
        let categoryColor = Color(hex: category.colorHex)
        Button {
            filterVM.setFilter(categoryId: category.id)
            HapticManager.selectionChanged()
        } label: {
            HStack(spacing: 4) {
                CategoryIconView(categoryId: category.id, size: 16)
                Text("\(category.localizedName(for: language)) (\(count))")
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color(.label) : Color(.secondaryLabel))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background {
                ZStack {
                    Capsule().fill(isSelected ? Color(.systemGray5) : Color(.systemGray6))
                    Capsule().strokeBorder(isSelected ? categoryColor : Color.clear, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }

    // MARK: Used Categories


    /// Nur Kategorien mit mindestens einer Activity — sortiert nach Anzahl absteigend.
    private var usedCategories: [Category] {
        filterVM.sortedUsedCategories(from: activities)
    }
}

// MARK: - Preview

#Preview("Category Chip Bar") {
    VStack(spacing: 20) {
        CategoryChipBar(
            filterVM: FilterViewModel(),
            activities: Activity.samples,
            language: "de"
        )
        .background(.ultraThinMaterial)

        Divider()

        CategoryChipBar(
            filterVM: {
                let vm = FilterViewModel()
                vm.setFilter(categoryId: "hiking")
                return vm
            }(),
            activities: Activity.samples,
            language: "de"
        )
        .background(.ultraThinMaterial)
    }
    .padding(.vertical)
    .background(Color(.systemBackground))
}
