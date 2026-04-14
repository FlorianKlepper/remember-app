// PermanentBottomSheet.swift
// ActivityTracker2 — Remember
// Immer sichtbares Bottom Sheet mit 3 Höhenstufen — ersetzt das dismissbare .sheet()

import SwiftUI
import MapKit

// MARK: - PermanentBottomSheet

/// Permanentes Bottom Sheet das sich NIEMALS schließt.
/// Drei Höhenstufen: small (15 %) · medium (50 %) · large (100 %).
/// Per Drag oder Velocity-Fling zwischen den Stufen navigieren.
///
/// Zeigt immer `mapVM.displayedActivities` — die vollständige gefilterte Liste.
/// `mapVM.highlightedActivityId` steuert Hervorhebung, Scroll-Position und Map-Pin.
/// Scroll-Snap: jede Zeile ist ein Snap-Punkt — beim Landen folgt die Map dem Pin.
struct PermanentBottomSheet: View {

    // MARK: Nested Types

    enum SheetDetent { case small, medium, large }

    // MARK: Environment

    @Environment(FilterViewModel.self)   private var filterVM
    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(LanguageManager.self)   private var languageManager

    // MARK: Inputs

    var mapVM: MapViewModel
    /// Wird bei jedem Detent-Wechsel aktualisiert — MapScreen nutzt es
    /// um Zoom + GPS + Plus Buttons mit dem Sheet mitbewegen zu lassen.
    @Binding var currentHeight: CGFloat

    // MARK: Private

    /// Alle Aktivitäten gefiltert nach aktivem Kategorie-Filter — für den large Detent (volle Liste).
    private var displayedActivities: [Activity] {
        activityVM.filteredActivities(categoryId: filterVM.selectedCategoryId)
    }

    private var currentLanguage: String {
        languageManager.currentLanguageCode
    }

    // MARK: State

    @State private var currentDetent: SheetDetent = .small
    @State private var dragOffset: CGFloat = 0
    @State private var selectedActivity: Activity? = nil

    /// Aktuell gesnappte Activity-ID — steuert Scroll-Position und Map-Sync.
    @State private var scrollPosition: Activity.ID? = nil

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            let screen   = geometry.size.height
            let minH     = screen * 0.12
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
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: -2)
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
        // Highlight von außen (z.B. Pin-Tap) → Scroll-Position synchronisieren
        .onChange(of: mapVM.highlightedActivityId) { _, newId in
            guard let newId, newId != scrollPosition else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollPosition = newId
            }
            // Sheet auf .medium hochfahren wenn aktuell .small
            if currentDetent == .small {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    currentDetent = .medium
                }
            }
        }
        // Detent-Wechsel → currentHeight nach außen propagieren
        .onChange(of: currentDetent) { _, detent in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                let screen = UIScreen.main.bounds.height
                switch detent {
                case .small:  currentHeight = screen * 0.12
                case .medium: currentHeight = screen * 0.5
                case .large:  currentHeight = screen
                }
            }
        }
    }

    // MARK: Small Content (15 %)

    private var smallContent: some View {
        Spacer().frame(height: 4)
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
                activityScrollView
            }
        }
    }

    // MARK: Large Content (100 %)

    private var largeContent: some View {
        VStack(spacing: 0) {

            // ── Sticky Header ────────────────────────────────────
            VStack(spacing: 0) {

                // Drag Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)

                // Titel-Zeile
                HStack {
                    Text(LocalizedStringKey("list.title"))
                        .font(.headline)
                        .padding(.leading, 16)

                    Spacer()

                    // Karte Button
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            currentDetent = .medium
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "map")
                                .font(.system(size: 13))
                            Text(LocalizedStringKey("tab.map"))
                                .font(.caption)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(.systemGray6)))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 8)

                // ── CategoryChipBar ──────────────────────────────
                CategoryChipBar(
                    filterVM: filterVM,
                    activities: activityVM.activities,
                    language: currentLanguage
                )
                .padding(.bottom, 4)

                Divider()
            }
            .background(Color(.systemBackground))

            // ── Liste mit aktivem Filter ─────────────────────────
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        if displayedActivities.isEmpty {
                            EmptyStateView(
                                config: filterVM.isFilterActive
                                    ? .filteredNoResults
                                    : .noActivities
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(displayedActivities) { activity in
                                let isHighlighted = activity.id == mapVM.highlightedActivityId
                                activityRow(activity: activity, isHighlighted: isHighlighted)
                                    .id(activity.id)
                                Divider()
                            }
                        }
                    }
                }
                .onChange(of: mapVM.highlightedActivityId) { _, newId in
                    if let newId {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(newId, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    // MARK: Shared Scroll View mit Snap

    /// Gemeinsame scrollbare Liste für medium und large — mit Snap-Verhalten.
    /// Jede Row ist ein Snap-Punkt; beim Landen folgt die Map dem Pin.
    private var activityScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(mapVM.displayedActivities) { activity in
                    VStack(spacing: 0) {
                        activityRow(
                            activity: activity,
                            isHighlighted: activity.id == mapVM.highlightedActivityId
                        )
                        .frame(height: rowHeight(for: activity))
                        Divider()
                    }
                    .id(activity.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollPosition)
        // Scroll-Snap → Map nachführen
        .onChange(of: scrollPosition) { _, newId in
            guard let newId, newId != mapVM.highlightedActivityId else { return }
            mapVM.highlightedActivityId = newId
            if let activity = mapVM.displayedActivities.first(where: { $0.id == newId }),
               let location = activity.location {
                mapVM.selectedLocation = location
                let center = mapVM.adjustedCenter(for: location.coordinate, span: mapVM.region.span)
                withAnimation(.easeInOut(duration: 0.4)) {
                    mapVM.region = MKCoordinateRegion(center: center, span: mapVM.region.span)
                }
            }
        }
        // Initiale Scroll-Position beim Erscheinen der Liste
        .onAppear {
            if scrollPosition == nil {
                scrollPosition = mapVM.highlightedActivityId
                    ?? mapVM.displayedActivities.first?.id
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

    /// Fixe Zeilenhöhe für sauberes Snap-Verhalten.
    /// Mit Text-Vorschau: 72 pt — ohne: 52 pt.
    private func rowHeight(for activity: Activity) -> CGFloat {
        let hasText = activity.text?.isBlank == false
        return hasText ? 72 : 52
    }

    private func heightFor(_ detent: SheetDetent, _ screen: CGFloat) -> CGFloat {
        switch detent {
        case .small:  return screen * 0.12
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
            (screen * 0.12, .small),
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
    let analytics   = AnalyticsManager()
    let mapVM       = MapViewModel()
    let filterVM    = FilterViewModel()
    let activityVM  = ActivityViewModel(analytics: analytics)
    let languageManager = LanguageManager()

    mapVM.displayedActivities   = Array(Activity.samples.prefix(5))
    mapVM.highlightedActivityId = Activity.samples.first?.id
    activityVM.activities       = Activity.samples

    return ZStack(alignment: .bottom) {
        Color(.systemGroupedBackground).ignoresSafeArea()
        PermanentBottomSheet(mapVM: mapVM, currentHeight: .constant(UIScreen.main.bounds.height * 0.12))
            .environment(filterVM)
            .environment(activityVM)
            .environment(languageManager)
    }
}
