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
            let baseH    = heightFor(currentDetent, screen)
            let minH     = screen * 0.15
            let displayH = max(baseH + dragOffset, minH)

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
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 28
                )
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: -2)
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 28
                )
            )
            .offset(y: screen - displayH)
            .gesture(dragGesture)
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
        // Tab "Karte" → Sheet klein
        .onReceive(NotificationCenter.default.publisher(for: .setSheetSmall)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDetent = .small
                dragOffset = 0
            }
            mapVM.currentSheetDetent = 0.15
        }
        // Tab "Liste" → Sheet gross
        .onReceive(NotificationCenter.default.publisher(for: .setSheetLarge)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDetent = .large
                dragOffset = 0
            }
            mapVM.currentSheetDetent = 1.0
        }
        // Nach Speichern einer Aktivität → Sheet auf medium
        .onReceive(NotificationCenter.default.publisher(for: .setSheetMedium)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDetent = .medium
                dragOffset = 0
            }
            mapVM.currentSheetDetent = 0.45
            NotificationCenter.default.post(name: .sheetBecameSmall, object: nil)
        }
    }

    // MARK: Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                let screen      = UIScreen.main.bounds.height
                let base        = heightFor(currentDetent, screen)
                let newH        = base - translation
                let minH        = screen * 0.15
                dragOffset = newH < minH ? minH - base : -translation
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.height

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if velocity > 0 {
                        switch currentDetent {
                        case .large:  currentDetent = .medium
                        case .medium: currentDetent = .small
                        case .small:  currentDetent = .small
                        }
                    } else {
                        switch currentDetent {
                        case .small:  currentDetent = .medium
                        case .medium: currentDetent = .large
                        case .large:  currentDetent = .large
                        }
                    }
                    dragOffset = 0
                }

                let detentAfterDrag = currentDetent
                syncMapAfterDrag(detent: currentDetent)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if detentAfterDrag == .large {
                        NotificationCenter.default.post(name: .sheetBecameLarge, object: nil)
                    } else {
                        NotificationCenter.default.post(name: .sheetBecameSmall, object: nil)
                    }
                }
            }
    }

    /// Karte nach Drag-Ende neu zentrieren.
    private func syncMapAfterDrag(detent: SheetDetent) {
        switch detent {
        case .small:
            mapVM.currentSheetDetent = 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                guard let activity = mapVM.displayedActivities
                    .first(where: { $0.id == mapVM.highlightedActivityId }),
                      let location = activity.location else { return }
                let center = mapVM.adjustedCenter(
                    for: location.coordinate,
                    span: mapVM.region.span,
                    sheetDetent: 0.15
                )
                withAnimation(.easeInOut(duration: 0.4)) {
                    mapVM.region = MKCoordinateRegion(center: center, span: mapVM.region.span)
                }
            }
        case .medium:
            mapVM.currentSheetDetent = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                let location: Location? = {
                    if let sel = mapVM.selectedLocation,
                       mapVM.displayedActivities.contains(where: { $0.location?.id == sel.id }) {
                        return sel
                    }
                    if let id = mapVM.highlightedActivityId,
                       let act = mapVM.displayedActivities.first(where: { $0.id == id }) {
                        return act.location
                    }
                    return nil
                }()
                guard let location else { return }
                let center = mapVM.adjustedCenter(
                    for: location.coordinate,
                    span: mapVM.region.span,
                    sheetDetent: 0.5
                )
                withAnimation(.easeInOut(duration: 0.4)) {
                    mapVM.region = MKCoordinateRegion(center: center, span: mapVM.region.span)
                }
            }
        case .large:
            mapVM.currentSheetDetent = 1.0
        }
    }

    // MARK: Small Content (15 %)

    private var smallContent: some View {
        Spacer().frame(height: 4)
    }

    // MARK: Medium Content (50 %)

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            mediumCountHeader
            Divider()
            if mapVM.displayedActivities.isEmpty {
                Text(LocalizedStringKey("bottomsheet.tap.pin"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(16)
            } else {
                mediumScrollView
            }
        }
    }

    @ViewBuilder
    private var mediumCountHeader: some View {
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
    }

    private var mediumScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    activityListItems(
                        activities: mapVM.displayedActivities,
                        highlighted: mapVM.highlightedActivityId
                    )
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.35)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: scrollPosition) { _, newId in
                guard let newId, newId != mapVM.highlightedActivityId else { return }
                mapVM.highlightedActivityId = newId
                if let activity = mapVM.displayedActivities.first(where: { $0.id == newId }),
                   let location = activity.location {
                    mapVM.selectedLocation = location
                    let center = mapVM.adjustedCenter(
                        for: location.coordinate,
                        span: mapVM.region.span,
                        sheetDetent: mapVM.currentSheetDetent
                    )
                    withAnimation(.easeInOut(duration: 0.4)) {
                        mapVM.region = MKCoordinateRegion(center: center, span: mapVM.region.span)
                    }
                }
            }
            .onChange(of: mapVM.highlightedActivityId) { _, newId in
                guard let newId,
                      let newActivity  = mapVM.displayedActivities.first(where: { $0.id == newId }),
                      let newLocation  = newActivity.location
                else { return }
                let currentLocation = mapVM.displayedActivities
                    .first(where: { $0.id == mapVM.previousHighlightedId })?.location
                mapVM.animateToPin(from: currentLocation, to: newLocation, currentSpan: mapVM.region.span)
                withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(newId, anchor: UnitPoint.top) }
            }
            .onAppear {
                if scrollPosition == nil {
                    scrollPosition = mapVM.highlightedActivityId ?? mapVM.displayedActivities.first?.id
                }
                if let id = mapVM.highlightedActivityId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(id, anchor: UnitPoint.top)
                    }
                }
            }
            .onChange(of: mapVM.displayedActivities.first?.id) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    let target = mapVM.highlightedActivityId ?? mapVM.displayedActivities.first?.id
                    if let id = target {
                        withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(id, anchor: UnitPoint.top) }
                    }
                }
            }
            .onChange(of: filterVM.selectedCategoryId) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let first = mapVM.displayedActivities.first {
                        withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(first.id, anchor: UnitPoint.top) }
                    }
                }
            }
        }
    }

    // MARK: Large Content (100 %)

    private var largeContent: some View {
        VStack(spacing: 0) {
            largeListHeader
            largeScrollView
        }
    }

    @ViewBuilder
    private var largeListHeader: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 8)

            CategoryChipBar(
                filterVM: filterVM,
                activities: activityVM.activities,
                language: currentLanguage
            )

            Divider()
                .padding(.top, 4)
        }
        .background(Color(.systemBackground))
    }

    private var largeScrollView: some View {
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
                        activityListItems(
                            activities: displayedActivities,
                            highlighted: mapVM.highlightedActivityId
                        )
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.35)
            }
            .onChange(of: mapVM.highlightedActivityId) { _, newId in
                guard let newId,
                      let newActivity  = mapVM.displayedActivities.first(where: { $0.id == newId }),
                      let newLocation  = newActivity.location
                else { return }
                let currentLocation = mapVM.displayedActivities
                    .first(where: { $0.id == mapVM.previousHighlightedId })?.location
                mapVM.animateToPin(from: currentLocation, to: newLocation, currentSpan: mapVM.region.span)
                withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(newId, anchor: UnitPoint.top) }
            }
            .onAppear {
                if let id = mapVM.highlightedActivityId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(id, anchor: UnitPoint.top)
                    }
                }
            }
            .onChange(of: displayedActivities.first?.id) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    let target = mapVM.highlightedActivityId ?? displayedActivities.first?.id
                    if let id = target {
                        withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(id, anchor: UnitPoint.top) }
                    }
                }
            }
            .onChange(of: filterVM.selectedCategoryId) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let first = displayedActivities.first {
                        withAnimation(.easeInOut(duration: 0.3)) { proxy.scrollTo(first.id, anchor: UnitPoint.top) }
                    }
                }
            }
        }
    }

    // MARK: Shared List Items

    /// Gemeinsame Listeinhalte für medium und large — Jahr-Header + Zeilen + Divider.
    @ViewBuilder
    private func activityListItems(
        activities: [Activity],
        highlighted: Activity.ID?
    ) -> some View {
        ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
            if index == 0 || activities[index - 1].yearInt != activity.yearInt {
                yearSeparator(yearInt: activity.yearInt)
            }
            activityRow(activity: activity, isHighlighted: activity.id == highlighted)
                .frame(minHeight: 72)
                .id(activity.id)
            Divider()
                .padding(.leading, 16)
        }
    }

    /// Jahr-Trennzeile.
    @ViewBuilder
    private func yearSeparator(yearInt: Int) -> some View {
        HStack(spacing: 0) {
            Text(String(format: "%d", yearInt))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
                .padding(.vertical, 6)
            Spacer()
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)
                .padding(.trailing, 16)
        }
        .background(Color(.systemGray6).opacity(0.5))
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

                // ── Datum links ──────────────────────────────────
                VStack(alignment: .center, spacing: 0) {
                    Text(activity.dayString)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(activity.monthString)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 40)

                // ── Titel + Ort + Text mitte ─────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.displayTitle)
                        .font(.headline)
                        .lineLimit(1)

                    if let city = activity.location?.city, !city.isBlank {
                        Text(city)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if let text = activity.text, !text.isBlank {
                        Text(text)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                // ── Sterne + Kategorie Icon rechts ───────────────
                VStack(alignment: .trailing, spacing: 4) {
                    if activity.starRating > 0 {
                        HStack(spacing: 2) {
                            ForEach(1...activity.starRating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color(hex: "#FFD700"))
                            }
                        }
                    }
                    CategoryIconView(categoryId: activity.categoryId, size: 36)
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

    private func heightFor(_ detent: SheetDetent, _ screen: CGFloat) -> CGFloat {
        switch detent {
        case .small:  return screen * 0.15
        case .medium: return screen * 0.45
        case .large:
            let topSafeArea = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.top ?? 47
            return screen - topSafeArea - 8
        }
    }
}

// MARK: - Preview

#Preview("Permanent Bottom Sheet — medium") {
    let analytics       = AnalyticsManager()
    let mapVM           = MapViewModel()
    let filterVM        = FilterViewModel()
    let activityVM      = ActivityViewModel(analytics: analytics)
    let languageManager = LanguageManager()

    mapVM.displayedActivities   = Array(Activity.samples.prefix(5))
    mapVM.highlightedActivityId = Activity.samples.first?.id
    activityVM.activities       = Activity.samples

    return ZStack(alignment: .bottom) {
        Color(.systemGroupedBackground).ignoresSafeArea()
        PermanentBottomSheet(mapVM: mapVM)
            .environment(filterVM)
            .environment(activityVM)
            .environment(languageManager)
    }
}
