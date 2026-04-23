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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                    // "Alle" Chip
                    allChip
                        .id("all")

                    // Kategorie Chips
                    ForEach(usedCategories, id: \.id) { category in
                        categoryChip(category)
                            .id(category.id)
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 44)
            // Aktiven Chip zentrieren wenn Filter wechselt
            .onChange(of: filterVM.selectedCategoryId) { _, newId in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    proxy.scrollTo(newId ?? "all", anchor: .center)
                }
            }
            // Beim Erscheinen aktiven Chip zentrieren
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(filterVM.selectedCategoryId ?? "all", anchor: .center)
                }
            }
        }
    }

    // MARK: Alle Chip

    @ViewBuilder
    private var allChip: some View {
        let isSelected = filterVM.selectedCategoryId == nil
        Button {
            filterVM.clearFilter()
            HapticManager.selectionChanged()
        } label: {
            Text("\(String(localized: "filter.all")) (\(activities.count))")
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    ZStack {
                        Capsule().fill(Color(.systemGray6))
                        Capsule().strokeBorder(isSelected ? Color(.label) : Color.clear, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
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
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? categoryColor : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? categoryColor : Color(.systemGray4),
                        lineWidth: isSelected ? 2.0 : 1.0
                    )
            )
            .shadow(
                color: isSelected ? categoryColor.opacity(0.3) : Color.black.opacity(0.06),
                radius: isSelected ? 6 : 3,
                x: 0,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    // MARK: Used Categories


    /// Nur Kategorien mit mindestens einer Activity — sortiert nach Anzahl absteigend.
    private var usedCategories: [Category] {
        filterVM.sortedUsedCategories(from: activities)
    }
}

// MARK: - Preview

#Preview("Category Chip Bar") {
    let analytics = AnalyticsManager()
    VStack(spacing: 20) {
        CategoryChipBar(
            filterVM: FilterViewModel(analytics: analytics),
            activities: Activity.samples,
            language: "de"
        )
        .background(.ultraThinMaterial)

        Divider()

        CategoryChipBar(
            filterVM: {
                let vm = FilterViewModel(analytics: analytics)
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
