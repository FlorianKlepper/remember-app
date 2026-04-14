// PermanentBottomSheet.swift
// ActivityTracker2 — Remember
// Immer sichtbares Bottom Sheet mit 3 Höhenstufen — ersetzt das dismissbare .sheet()

import SwiftUI

// MARK: - PermanentBottomSheet

/// Permanentes Bottom Sheet das sich NIEMALS schließt.
/// Drei Höhenstufen: small (15 %) · medium (50 %) · large (100 %).
/// Per Drag oder Velocity-Fling zwischen den Stufen navigieren.
///
/// Zeigt immer `mapVM.displayedActivities` — die vollständige gefilterte Liste.
/// `mapVM.highlightedActivityId` steuert Hervorhebung und automatisches Scrollen.
struct PermanentBottomSheet: View {

    // MARK: Nested Types

    enum SheetDetent { case small, medium, large }

    // MARK: Inputs

    var mapVM: MapViewModel

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
        // Highlight wechselt → Sheet auf .medium hochfahren wenn aktuell .small
        .onChange(of: mapVM.highlightedActivityId) { _, newId in
            guard newId != nil, currentDetent == .small else { return }
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
            if !mapVM.displayedActivities.isEmpty {
                Text("\(mapVM.displayedActivities.count)")
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

    // MARK: Medium Content (50 %)

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Count-Header ─────────────────────────────────────
            if !mapVM.displayedActivities.isEmpty {
                let count = mapVM.displayedActivities.count
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

            if mapVM.displayedActivities.isEmpty {
                Text(LocalizedStringKey("bottomsheet.tap.pin"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(mapVM.displayedActivities) { activity in
                                activityRow(
                                    activity: activity,
                                    isHighlighted: activity.id == mapVM.highlightedActivityId
                                )
                                .id(activity.id)
                                Divider()
                            }
                        }
                    }
                    .onChange(of: mapVM.highlightedActivityId) { _, newId in
                        guard let newId else { return }
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo(newId, anchor: .center)
                        }
                    }
                    .onAppear {
                        if let id = mapVM.highlightedActivityId {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    // MARK: Large Content (100 %)

    private var largeContent: some View {
        VStack(spacing: 0) {

            // ── Sticky Header ────────────────────────────────────
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)

                HStack {
                    Text(LocalizedStringKey("list.title"))
                        .font(.headline)
                        .padding(.leading, 16)

                    Spacer()

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
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(mapVM.displayedActivities) { activity in
                            activityRow(
                                activity: activity,
                                isHighlighted: activity.id == mapVM.highlightedActivityId
                            )
                            .id(activity.id)
                            Divider()
                        }
                    }
                }
                .onChange(of: mapVM.highlightedActivityId) { _, newId in
                    guard let newId else { return }
                    withAnimation(.easeInOut(duration: 0.4)) {
                        proxy.scrollTo(newId, anchor: .center)
                    }
                }
                .onAppear {
                    if let id = mapVM.highlightedActivityId {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: Row Helper

    /// Einheitliche Listenzeile für alle Detent-Stufen.
    /// Hervorgehobene Zeile zeigt farbigen Streifen links und hellgrauen Hintergrund.
    @ViewBuilder
    private func activityRow(activity: Activity, isHighlighted: Bool) -> some View {
        let categoryColor = Color(hex:
            (Category.mvpCategories + Category.plusCategories)
                .first { $0.id == activity.categoryId }?.colorHex ?? "888888"
        )

        HStack(spacing: 0) {
            // ── Farbiger Streifen links ──────────────────────────
            Rectangle()
                .fill(isHighlighted ? categoryColor : Color.clear)
                .frame(width: 3)
                .padding(.vertical, 4)

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
            .padding(.horizontal, 13)   // 16 - 3 (Streifen-Breite)
            .padding(.vertical, 12)
        }
        .background(isHighlighted ? Color(.systemGray6) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            mapVM.onActivityTapped(activity)
            selectedActivity = activity
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

    mapVM.displayedActivities = Array(Activity.samples.prefix(5))
    mapVM.highlightedActivityId = Activity.samples.first?.id

    return ZStack(alignment: .bottom) {
        Color(.systemGroupedBackground).ignoresSafeArea()
        PermanentBottomSheet(mapVM: mapVM)
    }
}
