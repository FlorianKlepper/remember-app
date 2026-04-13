// FilterStatusBanner.swift
// ActivityTracker2 — Remember
// Einblendbarer Banner wenn ein Kategorie-Filter aktiv ist

import SwiftUI

// MARK: - FilterStatusBanner

/// Zeigt den aktiven Filter als schmalen Banner mit Dismiss-Button.
/// Wird via `withAnimation` ein- und ausgeblendet wenn `filterVM.isFilterActive` sich ändert.
/// Transition: `.move(edge: .top).combined(with: .opacity)`.
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
            HStack(spacing: 8) {

                // ── Mini-Icon ─────────────────────────────────────
                CategoryIconView(
                    categoryId: filterVM.selectedCategoryId ?? "",
                    size: 20
                )

                // ── Label ─────────────────────────────────────────
                Text("filter.status.prefix") // "Gefiltert:"
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(categoryName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                // ── Dismiss ───────────────────────────────────────
                Button {
                    withAnimation(.easeInOut(duration: AppConstants.animationStandard)) {
                        filterVM.clearFilter()
                    }
                    HapticManager.lightImpact()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color(.systemGray5), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                categoryColor.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
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

        Text("Kein Filter → kein Banner")
            .font(.caption)
            .foregroundStyle(.secondary)

        FilterStatusBanner(
            filterVM: FilterViewModel(),
            language: "de"
        )
        // → zeigt nichts
    }
    .padding(.vertical, 32)
    .frame(maxWidth: .infinity)
    .background(Color(.systemBackground))
}
