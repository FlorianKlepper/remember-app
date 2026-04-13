// ActivityDetailScreen.swift
// ActivityTracker2 — Remember
// Detailansicht einer einzelnen Aktivität

import SwiftUI

// MARK: - ActivityDetailScreen

/// Zeigt alle Details einer Activity: Kategorie-Header, Karte, Ort und Freitext.
/// Über das Kontextmenü in der Toolbar kann die Activity bearbeitet oder gelöscht werden.
struct ActivityDetailScreen: View {

    // MARK: Parameter

    let activity: Activity

    // MARK: Environment

    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(\.modelContext)         private var modelContext
    @Environment(\.dismiss)              private var dismiss

    // MARK: State

    @State private var showEditSheet      = false
    @State private var showDeleteConfirm  = false

    // MARK: Private

    private let brandColor = Color(hex: "#E8593C")

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── Header-Karte ────────────────────────────────────
                headerCard

                // ── Karte & Ort ─────────────────────────────────────
                if let location = activity.location {
                    MiniMapView(coordinate: location.coordinate)
                        .padding(.horizontal)

                    locationLabel(location: location)
                }

                // ── Freitext ────────────────────────────────────────
                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.body)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle(activity.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                actionsMenu
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditActivityScreen(activity: activity)
        }
        .confirmationDialog(
            String(localized: "activity.delete.confirm.title",
                   defaultValue: "Aktivität löschen?"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(
                String(localized: "button.delete", defaultValue: "Löschen"),
                role: .destructive
            ) {
                activityVM.deleteActivity(activity, context: modelContext)
                dismiss()
            }
            Button(
                String(localized: "button.cancel", defaultValue: "Abbrechen"),
                role: .cancel
            ) {}
        } message: {
            Text("activity.delete.confirm.message")
        }
    }

    // MARK: Sub-Views

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 14) {
            CategoryIconView(categoryId: activity.categoryId, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .lineLimit(2)

                Text(activity.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if activity.isFavorite {
                    Label(
                        String(localized: "activity.favorite.label",
                               defaultValue: "Favorit"),
                        systemImage: "star.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(brandColor)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func locationLabel(location: Location) -> some View {
        let parts = [location.city, location.region, location.country]
            .compactMap { $0 }
        if !parts.isEmpty {
            Label(parts.joined(separator: ", "), systemImage: "mappin")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }

    private var actionsMenu: some View {
        Menu {
            Button {
                showEditSheet = true
            } label: {
                Label(
                    String(localized: "button.edit", defaultValue: "Bearbeiten"),
                    systemImage: "pencil"
                )
            }

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label(
                    String(localized: "button.delete", defaultValue: "Löschen"),
                    systemImage: "trash"
                )
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// MARK: - Preview

#Preview("Activity Detail Screen") {
    let analytics = AnalyticsManager()
    let actVM     = ActivityViewModel(analytics: analytics)

    return NavigationStack {
        ActivityDetailScreen(activity: Activity.preview)
    }
    .environment(actVM)
}
