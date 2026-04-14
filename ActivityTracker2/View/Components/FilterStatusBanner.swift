// FilterStatusBanner.swift
// ActivityTracker2 — Remember
// Dezenter Filter-Chip am rechten Rand — gleiche Optik wie aktiver CategoryChip

import SwiftUI

// MARK: - FilterStatusBanner

/// Zeigt den aktiven Filter als kompakte Pill am rechten Rand.
/// Design: systemGray6 Hintergrund + farbiger Rand — wie aktiver Chip in der ChipBar.
/// Transition: von rechts einfahren / ausfahren.
struct FilterStatusBanner: View {

    // MARK: Parameter

    var filterVM: FilterViewModel
    let language: String

    // MARK: Private

    private var activeCategory: Category? {
        guard let id = filterVM.selectedCategoryId else { return nil }
        return (Category.mvpCategories + Category.plusCategories)
            .first(where: { $0.id == id })
    }

    private var categoryColor: Color {
        Color(hex: activeCategory?.colorHex ?? "#8E8E93")
    }

    private var categoryName: String {
        guard let category = activeCategory else { return "" }
        return category.localizedName(for: language)
    }

    // MARK: Body

    var body: some View {
        if filterVM.isFilterActive {
            HStack {
                Spacer()

                HStack(spacing: 6) {

                    // ── Kategorie-Icon ────────────────────────────
                    CategoryIconView(
                        categoryId: filterVM.selectedCategoryId ?? "",
                        size: 16
                    )

                    // ── Label übereinander ────────────────────────
                    VStack(alignment: .leading, spacing: 1) {
                        Text(LocalizedStringKey("filter.active"))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text(categoryName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }

                    // ── Dismiss-Button ────────────────────────────
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            filterVM.clearFilter()
                        }
                        HapticManager.lightImpact()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(5)
                            .background(Circle().fill(Color(.systemGray4)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))
                        RoundedRectangle(cornerRadius: 10).strokeBorder(categoryColor, lineWidth: 1.5)
                    }
                }
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 12)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview("Filter Status Banner") {
    VStack(spacing: 16) {
        FilterStatusBanner(
            filterVM: {
                let vm = FilterViewModel()
                vm.setFilter(categoryId: "hiking")
                return vm
            }(),
            language: "de"
        )
        FilterStatusBanner(
            filterVM: {
                let vm = FilterViewModel()
                vm.setFilter(categoryId: "restaurant")
                return vm
            }(),
            language: "de"
        )
        FilterStatusBanner(
            filterVM: FilterViewModel(),
            language: "de"
        )
        // → zeigt nichts
    }
    .padding(.vertical, 32)
    .frame(maxWidth: .infinity)
    .background(Color(.systemGroupedBackground))
}
