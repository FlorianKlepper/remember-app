// ActivityDetailScreen.swift
// ActivityTracker2 — Remember
// Detailansicht einer einzelnen Aktivität

import SwiftUI
import SwiftData
import MapKit

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
    @State private var showShareSheet    = false

    // MARK: Computed — Share

    /// Apple Maps URL für den Ort der Activity.
    private var mapsURL: URL? {
        guard let location = activity.location else { return nil }
        let lat  = location.latitude
        let lon  = location.longitude
        let name = (location.locationName ?? location.city ?? "")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?ll=\(lat),\(lon)&q=\(name)")
    }

    /// Teile-Text mit Titel und Ort der Activity.
    private var shareText: String {
        let poi  = activity.location?.locationName ?? ""
        let city = activity.location?.city ?? ""
        let locationText = poi.isEmpty ? city : city.isEmpty ? poi : "\(poi), \(city)"
        return """
        \(activity.displayTitle)
        📍 \(locationText)
        """
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── 1. Karte ────────────────────────────────────────
                if let location = activity.location {
                    MiniMapView(coordinate: location.coordinate, categoryId: activity.categoryId)
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

                        let poi  = activity.location?.locationName ?? ""
                        let city = activity.location?.city ?? ""

                        if !poi.isEmpty && !city.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#E8593C"))
                                Text("\(poi) · \(city)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else if !poi.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#E8593C"))
                                Text(poi)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else if !city.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#E8593C"))
                                Text(city)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
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

                // ── 5. Foto ─────────────────────────────────────────
                if let photoData = activity.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
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

            // ── Trailing: Share, Papierkorb, Bearbeiten, Fertig ──
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }

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

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: "#E8593C"))
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditActivityScreen(activity: activity)
        }
        .sheet(isPresented: $showShareSheet) {
            VStack(spacing: 0) {

                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // Titel
                Text(String(localized: "share.title", defaultValue: "Ort teilen"))
                    .font(.headline)
                    .padding(.bottom, 20)

                // Optionen
                VStack(spacing: 6) {

                    // Apple Maps teilen
                    if let url = mapsURL {
                        ShareLink(
                            item: url,
                            subject: Text(activity.displayTitle),
                            message: Text(shareText)
                        ) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(
                                            colors: [Color(hex: "00C7F5"), Color(hex: "0A84FF")],
                                            startPoint: .top,
                                            endPoint: .bottom))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "map.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "share.maps.title",
                                                defaultValue: "In Maps öffnen"))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "share.maps.subtitle",
                                                defaultValue: "Ort in Apple Maps anzeigen"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)
                    }

                    // Koordinaten + Maps-Link teilen
                    if let location = activity.location {
                        ShareLink(
                            item: "\(shareText)\n🗺 https://maps.apple.com/?ll=\(location.latitude),\(location.longitude)"
                        ) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#E8593C"))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "share.coords.title",
                                                defaultValue: "Ort teilen"))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "share.coords.subtitle",
                                                defaultValue: "Mit Maps Link"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Abbrechen
                Button {
                    showShareSheet = false
                } label: {
                    Text(String(localized: "button.cancel", defaultValue: "Abbrechen"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 32)
            }
            .presentationDetents([.fraction(0.35)])
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
