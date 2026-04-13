// PermanentBottomSheet.swift
// ActivityTracker2 — Remember
// Immer sichtbares Bottom Sheet mit 3 Höhenstufen — ersetzt das dismissbare .sheet()

import SwiftUI

// MARK: - PermanentBottomSheet

/// Permanentes Bottom Sheet das sich NIEMALS schließt.
/// Drei Höhenstufen: small (15 %) · medium (50 %) · large (100 %).
/// Per Drag oder Velocity-Fling zwischen den Stufen navigieren.
/// Reagiert automatisch auf Pin-Taps: snap von .small auf .medium.
struct PermanentBottomSheet: View {

    // MARK: Nested Types

    enum SheetDetent { case small, medium, large }

    // MARK: Inputs

    var mapVM: MapViewModel
    var activityVM: ActivityViewModel

    // MARK: State

    @State private var currentDetent: SheetDetent = .small
    @State private var dragOffset: CGFloat = 0
    @State private var selectedActivity: Activity? = nil

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            let screen   = geometry.size.height
            let minH     = screen * 0.15
            let currentH = heightFor(currentDetent, screen)
            let displayH = max(currentH + dragOffset, minH)

            VStack(spacing: 0) {

                // ── Drag Handle — nur für .small und .medium ─────────
                // Im .large Zustand übernimmt largeContent seinen eigenen
                // sticky Header mit Drag-Pille und Karte-Button.
                if currentDetent != .large {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                }

                // ── Content je nach Stufe ────────────────────────────
                Group {
                    switch currentDetent {
                    case .small:  smallContent
                    case .medium: mediumContent
                    case .large:  largeContent
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: displayH)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: -2)
                    .ignoresSafeArea()
            )
            .offset(y: screen - displayH)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newH = currentH - value.translation.height
                        // Minimum erzwingen — Sheet kann nicht unter minH
                        dragOffset = newH >= minH ? newH - currentH : minH - currentH
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndTranslation.height
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            if velocity < -300 {
                                currentDetent = nextDetent(up: true)
                            } else if velocity > 300 {
                                currentDetent = nextDetent(up: false)
                            } else {
                                snapToNearest(current: currentH, screen: screen)
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $selectedActivity) { activity in
            NavigationStack {
                ActivityDetailScreen(activity: activity)
            }
        }
        // Pin getappt → Sheet automatisch auf .medium hochfahren
        .onChange(of: mapVM.selectedLocation?.id) { _, _ in
            guard !mapVM.activitiesAtPin.isEmpty,
                  currentDetent == .small else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                currentDetent = .medium
            }
        }
    }

    // MARK: Small Content (15 %)

    private var smallContent: some View {
        HStack {
            Image(systemName: "chevron.up")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("bottomsheet.swipe.up")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if !mapVM.activitiesAtPin.isEmpty {
                Text("\(mapVM.activitiesAtPin.count)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(hex: "#E8593C")))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: Row Helpers

    /// Erweiterte Zeile für 1–3 Aktivitäten — zeigt Datum, Stadt und erste Textzeile.
    @ViewBuilder
    private func extendedRow(activity: Activity) -> some View {
        HStack(alignment: .top, spacing: 12) {
            CategoryIconView(categoryId: activity.categoryId, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text([activity.formattedDate, activity.location?.city]
                    .compactMap { $0 }
                    .joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { selectedActivity = activity }
    }

    /// Einfache Zeile für 4+ Aktivitäten — kompakt wie `ActivityRowView`.
    @ViewBuilder
    private func simpleRow(activity: Activity) -> some View {
        HStack(spacing: 12) {
            CategoryIconView(categoryId: activity.categoryId, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                Text([activity.formattedDate, activity.location?.city]
                    .compactMap { $0 }
                    .joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let text = activity.text, !text.isBlank {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { selectedActivity = activity }
    }

    // MARK: Medium Content (50 %)

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Count-Header ─────────────────────────────────────
            if !mapVM.activitiesAtPin.isEmpty {
                let count = mapVM.activitiesAtPin.count
                let label = count == 1
                    ? String(localized: "bottomsheet.activities.count.few")
                    : String(localized: "bottomsheet.activities")
                HStack {
                    Text("\(count) \(label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            Divider()

            if mapVM.activitiesAtPin.isEmpty {
                Text(LocalizedStringKey("bottomsheet.tap.pin"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(mapVM.activitiesAtPin) { activity in
                            if mapVM.activitiesAtPin.count <= 3 {
                                extendedRow(activity: activity)
                            } else {
                                simpleRow(activity: activity)
                            }
                            Divider()
                        }
                    }
                }
            }
        }
    }

    // MARK: Large Content (100 %)

    private var largeContent: some View {
        let activities = mapVM.activitiesAtPin.isEmpty
            ? activityVM.activities
            : mapVM.activitiesAtPin

        return VStack(spacing: 0) {

            // ── Sticky Header ────────────────────────────────────
            VStack(spacing: 8) {

                // Drag-Pille — visueller Hinweis zum Runterziehen
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)

                HStack {
                    Text(LocalizedStringKey("list.title"))
                        .font(.headline)
                        .padding(.leading, 16)

                    Spacer()

                    // Karte-Button — springt zurück zu .medium
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            currentDetent = .medium
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "map")
                                .font(.system(size: 13))
                            Text(LocalizedStringKey("list.back.map"))
                                .font(.caption)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(.systemGray6)))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 8)

                Divider()
            }
            .background(Color(.systemBackground))

            // ── Scrollbare Liste ─────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(activities) { activity in
                        HStack(spacing: 12) {
                            CategoryIconView(categoryId: activity.categoryId, size: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.displayTitle)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text([activity.formattedDate, activity.location?.city]
                                    .compactMap { $0 }
                                    .joined(separator: " · "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if let text = activity.text, !text.isBlank {
                                    Text(text)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }

                            Spacer()

                            if activity.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedActivity = activity }

                        Divider()
                    }
                }
            }
        }
    }

    // MARK: Helpers

    private func heightFor(_ detent: SheetDetent, _ screen: CGFloat) -> CGFloat {
        switch detent {
        case .small:  return screen * 0.15
        case .medium: return screen * 0.5
        case .large:  return screen
        }
    }

    private func nextDetent(up: Bool) -> SheetDetent {
        switch currentDetent {
        case .small:  return up ? .medium : .small
        case .medium: return up ? .large  : .small
        case .large:  return up ? .large  : .medium
        }
    }

    /// Snapped zu der Höhenstufe die dem aktuellen `dragOffset + currentH` am nächsten ist.
    private func snapToNearest(current currentH: CGFloat, screen: CGFloat) {
        let targetH: CGFloat = currentH + dragOffset
        let candidates: [(CGFloat, SheetDetent)] = [
            (screen * 0.15, .small),
            (screen * 0.5,  .medium),
            (screen,        .large),
        ]
        currentDetent = candidates.min {
            abs($0.0 - targetH) < abs($1.0 - targetH)
        }?.1 ?? .small
    }
}

// MARK: - Preview

#Preview("Permanent Bottom Sheet — medium") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel()

    activityVM.activities = Activity.samples
    mapVM.activitiesAtPin = Array(Activity.samples.prefix(3))
    mapVM.selectedLocation = Activity.samples.first?.location
    mapVM.selectedActivityIndex = 0

    return ZStack(alignment: .bottom) {
        Color(.systemGroupedBackground).ignoresSafeArea()
        PermanentBottomSheet(mapVM: mapVM, activityVM: activityVM)
    }
}
