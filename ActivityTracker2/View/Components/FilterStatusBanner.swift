// FilterStatusBanner.swift
// ActivityTracker2 — Remember
// Rechtsbündige Filter-Pill mit Kategorie-Farbe und Dismiss-Button

import SwiftUI

// MARK: - FilterStatusBanner

/// Zeigt den aktiven Filter als kompakte Pill am rechten Rand.
/// Slide-in von rechts, Slide-out nach rechts.
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

                HStack(spacing: 8) {

                    // ── Label übereinander ────────────────────────
                    VStack(alignment: .leading, spacing: 1) {
                        Text(LocalizedStringKey("filter.active"))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))

                        Text(categoryName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
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
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(Circle().fill(.white.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(categoryColor)
                        .shadow(color: categoryColor.opacity(0.4), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.trailing, 12)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview("Filter Status Banner") {
    VStack(spacing: 24) {
        Text("Aktiver Filter")
            .font(.caption)
            .foregroundStyle(.secondary)

        FilterStatusBanner(
            filterVM: {
                let vm = FilterViewModel()
                vm.setFilter(categoryId: "hiking")
                return vm
            }(),
            language: "de"
        )

        Text("Anderer Filter")
            .font(.caption)
            .foregroundStyle(.secondary)

        FilterStatusBanner(
            filterVM: {
                let vm = FilterViewModel()
                vm.setFilter(categoryId: "restaurant")
                return vm
            }(),
            language: "de"
        )
    }
    .padding(.vertical, 32)
    .frame(maxWidth: .infinity)
    .background(Color(.systemGroupedBackground))
}
