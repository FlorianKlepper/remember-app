// ActivityDetailScreen.swift
// ActivityTracker2 — Remember
// Detailansicht einer einzelnen Aktivität

import SwiftUI
import SwiftData

// MARK: - ActivityDetailScreen

/// Zeigt alle Details einer Activity: Karte, Kategorie-Header, Ort und Freitext.
/// Toolbar: chevron.left (zurück), trash (löschen), square.and.pencil (bearbeiten).
struct ActivityDetailScreen: View {

    // MARK: Parameter

    let activity: Activity

    // MARK: Environment

    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(\.modelContext)         private var modelContext
    @Environment(\.dismiss)              private var dismiss

    // MARK: State

    @State private var showEditSheet     = false
    @State private var showDeleteConfirm = false

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── 1. Karte ────────────────────────────────────────
                if let location = activity.location {
                    MiniMapView(coordinate: location.coordinate)
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                }

                // ── 2. Kategorie + Titel + Datum ────────────────────
                HStack(alignment: .top, spacing: 12) {
                    CategoryIconView(categoryId: activity.categoryId, size: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.displayTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(2)

                        Text(activity.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let city = activity.location?.city {
                            Text(city)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)

                // ── 3. Freitext ─────────────────────────────────────
                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.body)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }

                // ── 4. Sterne-Bewertung (nur wenn > 0) ──────────────
                if activity.starRating > 0 {
                    StarRatingView(
                        rating: Binding(
                            get: { activity.starRating },
                            set: { _ in }
                        ),
                        isEditable: false
                    )
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle(activity.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            // ── Zurück (nur Symbol) ──────────────────────────────
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }

            // ── Trailing: Papierkorb links, Bearbeiten rechts ────
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                }

                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
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
