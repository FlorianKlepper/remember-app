// PermanentBottomSheet.swift
// ActivityTracker2 — Remember
// Immer sichtbares Bottom Sheet mit 3 Höhenstufen — ersetzt das dismissbare .sheet()

import SwiftUI
import MapKit

// MARK: - ScrollOffsetKey

/// PreferenceKey zum Tracken des vertikalen Scroll-Offsets — iOS 17 kompatibel.
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - RowTracker

/// Unsichtbare Hilfsview die den `minY`-Frame einer Row im benannten Koordinatenraum trackt.
/// Wird als `.background()` auf jede Listenzeile gesetzt.
private struct RowTracker: View {
    let activityId: Activity.ID
    let onFrameChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .named("scrollSpace")).minY) { _, _ in
                    onFrameChange(geo.frame(in: .named("scrollSpace")))
                }
        }
    }
}

// MARK: - PermanentBottomSheet

/// Permanentes Bottom Sheet das sich NIEMALS schließt.
/// Drei Höhenstufen: small (15 %) · medium (50 %) · large (100 %).
/// Per Drag oder Velocity-Fling zwischen den Stufen navigieren.
///
/// Kategorie-Navigation: TabView mit PageTabViewStyle —
/// jede Kategorie ist eine eigene Seite. User wischt horizontal wie bei einem Carousel.
/// `mapVM.highlightedActivityId` steuert Hervorhebung und Map-Pin-Sync.
struct PermanentBottomSheet: View {

    // MARK: Nested Types

    enum SheetDetent { case small, medium, large }

    // MARK: Environment

    @Environment(FilterViewModel.self)   private var filterVM
    @Environment(ActivityViewModel.self) private var activityVM
    @Environment(LanguageManager.self)   private var languageManager
    @Environment(AnalyticsManager.self)  private var analyticsManager

    // MARK: Inputs

    var mapVM: MapViewModel

    // MARK: Private

    private var currentLanguage: String {
        languageManager.currentLanguageCode
    }

    // MARK: State

    @State private var currentDetent:    SheetDetent = .small
    @State private var dragOffset:       CGFloat     = 0
    @State private var selectedActivity: Activity?   = nil

    /// Aktive TabView-Seite — Index in `categoryPages`.
    @State private var selectedPageIndex: Int = 0

    /// Horizontaler Offset der Liste beim Kategorie-Wechsel.
    @State private var listOffset:  CGFloat = 0

    /// Opacity der Liste beim Kategorie-Wechsel.
    @State private var listOpacity: Double  = 1.0

    /// Wechselt bei jedem Kategorie-Swipe — zwingt den ScrollView zu einem Neurender.
    @State private var listId: UUID = UUID()

    /// ID der Aktivität die gerade oben im ScrollView eingeschnappt ist.
    /// Wird von `.scrollPosition(id:)` automatisch aktualisiert.
    @State private var scrollPosition: Activity.ID? = nil

    /// Aktueller vertikaler Scroll-Offset — via PreferenceKey getrackt.
    @State private var scrollOffset: CGFloat = 0

    /// Index der aktuell sichtbaren Aktivität in `currentActivities`.
    @State private var currentIndex: Int = 0

    /// Timer der nach dem Stopp des ScrollView feuert — forciert highlightedActivityId Update.
    @State private var scrollStopTimer: Timer? = nil

    /// Velocity beim letzten DragGesture.onEnded — für zukünftige Snap-Logik.
    @State private var lastVelocity: CGFloat = 0

    /// ID der aktuell obersten sichtbaren Row — via GeometryReader getrackt.
    @State private var topRowId: Activity.ID? = nil

    /// Sichtbarkeitsanteil der obersten Row (0.0–1.0) — für 50%-Regel.
    @State private var topRowVisible: CGFloat = 1.0

    /// True während ein programmatischer Snap läuft — unterdrückt GeometryReader-Updates.
    @State private var isSnapping: Bool = false

    /// True während der User den ScrollView berührt — verhindert programmatisches Scrollen.
    @State private var isUserScrolling: Bool = false

    /// Vertikale Swipe-Geschwindigkeit — bestimmt Snap-Richtung.
    @State private var dragVelocity: CGFloat = 0

    /// Y-Offset beim Beginn des Drags — für Richtungsberechnung.
    @State private var dragStartOffset: CGFloat = 0

    // MARK: Body

    var body: some View {
        GeometryReader { geometry in
            let screen   = geometry.size.height
            let baseH    = heightFor(currentDetent, screen)
            let minH     = screen * AppConstants.bottomSheetSmall
            let displayH = max(baseH + dragOffset, minH)

            VStack(spacing: 0) {

                // ── Drag Handle — nur für .small und .medium ─────────
                // NUR der Handle erhält die Drag-Gesture (nicht der ScrollView)
                if currentDetent != .large {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .gesture(sheetDragGesture)
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
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $selectedActivity) { activity in
            NavigationStack {
                ActivityDetailScreen(activity: activity)
            }
        }
        // Highlight von außen (z.B. Pin-Tap) → Sheet auf .medium hochfahren
        .onChange(of: mapVM.highlightedActivityId) { _, newId in
            guard newId != nil else { return }
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
                dragOffset    = 0
            }
            mapVM.currentSheetDetent = AppConstants.bottomSheetSmall
            NotificationCenter.default.post(name: .sheetSizeChanged, object: true)
        }
        // Tab "Liste" → Sheet gross
        .onReceive(NotificationCenter.default.publisher(for: .setSheetLarge)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDetent = .large
                dragOffset    = 0
            }
            mapVM.currentSheetDetent = 1.0
            NotificationCenter.default.post(name: .sheetSizeChanged, object: false)
            analyticsManager.trackFirstListViewed()
        }
        // Nach Speichern einer Aktivität → Sheet auf medium
        .onReceive(NotificationCenter.default.publisher(for: .setSheetMedium)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDetent = .medium
                dragOffset    = 0
            }
            mapVM.currentSheetDetent = 0.45
            NotificationCenter.default.post(name: .sheetBecameSmall, object: nil)
            NotificationCenter.default.post(name: .sheetSizeChanged, object: false)
        }
        // Neue Aktivität gespeichert → zur neuesten Aktivität scrollen
        // (Filter-Reset läuft separat via .filterCleared in MapScreen)
        .onReceive(NotificationCenter.default.publisher(for: .activitySaved)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let newest = activityVM.activities
                    .sorted(by: { $0.date > $1.date })
                    .first {
                    mapVM.highlightedActivityId = newest.id
                }
            }
        }
    }

    // MARK: Sheet Drag Gesture

    /// Drag-Gesture für den Handle — steuert Sheet-Höhe.
    /// Liegt ausschließlich auf dem Handle-Element, nicht auf dem ScrollView.
    private var sheetDragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let screen = UIScreen.main.bounds.height
                let base   = heightFor(currentDetent, screen)
                let newH   = base - value.translation.height
                let minH   = screen * AppConstants.bottomSheetSmall
                dragOffset = newH < minH ? minH - base : -value.translation.height
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
                    NotificationCenter.default.post(
                        name: .sheetSizeChanged,
                        object: detentAfterDrag == .small
                    )
                }
            }
    }

    // MARK: Category Pages

    /// Alle Kategorie-Seiten: Index 0 = `nil` ("Alle"), danach sortiert nach Anzahl absteigend.
    private var categoryPages: [Category?] {
        var pages: [Category?] = [nil]
        pages += filterVM.sortedUsedCategories(from: activityVM.activities).map { Optional($0) }
        return pages
    }

    /// Aktivitäten der aktuell aktiven Seite (gefiltert nach `filterVM.selectedCategoryId`).
    private var currentActivities: [Activity] {
        activityVM.activities
            .filter { filterVM.selectedCategoryId == nil || $0.categoryId == filterVM.selectedCategoryId }
            .sorted { $0.date > $1.date }
    }

    // MARK: Content ScrollView

    /// Vertikaler ScrollView mit manuell gesteuertem Paging.
    /// Horizontales Wischen wechselt Kategorie, vertikales Wischen snappt zur nächsten/vorherigen Activity.
    @ViewBuilder
    private var contentScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if currentActivities.isEmpty {
                        EmptyStateView(
                            config: filterVM.isFilterActive
                                ? .filteredNoResults
                                : .noActivities
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(Array(currentActivities.enumerated()), id: \.element.id) { _, activity in
                            activityRow(activity: activity)
                                .frame(height: 72)
                                .id(activity.id)
                                .background(
                                    RowTracker(activityId: activity.id) { frame in
                                        updateTopRow(frame: frame, activityId: activity.id)
                                    }
                                )
                            Divider().padding(.leading, 16)
                        }
                        Color.clear
                            .frame(height: UIScreen.main.bounds.height * 0.32)
                    }
                }
            }
            .coordinateSpace(name: "scrollSpace")
            .scrollPosition(id: $scrollPosition, anchor: .top)
            .id(listId)
            .offset(x: listOffset)
            .opacity(listOpacity)
            // Unified Gesture: horizontal → Kategorie-Wechsel, vertikal → Paging
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let h      = value.translation.width
                        let v      = value.translation.height
                        let vel    = value.velocity.height
                        let absVel = abs(vel)
                        lastVelocity = vel

                        // Horizontal → Kategorie wechseln
                        guard !(abs(h) > abs(v) * 1.5 && abs(h) > 40) else {
                            if h < -40     { swipeToNext() }
                            else if h > 40 { swipeToPrevious() }
                            return
                        }

                        if absVel < 150 {
                            // TYP 1: Kurz warten bis scrollPosition aktualisiert ist
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.snapToCurrentPosition(proxy: proxy)
                            }

                        } else {
                            // TYP 2 + TYP 3: velocity-basierte Wartezeit bis ScrollView stoppt
                            let waitTime = min(Double(absVel) / 1000.0, 1.5)
                            scrollStopTimer?.invalidate()
                            scrollStopTimer = Timer.scheduledTimer(
                                withTimeInterval: waitTime,
                                repeats: false
                            ) { _ in
                                DispatchQueue.main.async {
                                    self.snapToCurrentPosition(proxy: proxy)
                                }
                            }
                        }
                    }
            )
            // Map-Sync nach manuellem Scrollen — kein Timer, kein zweiter Snap
            .onChange(of: scrollPosition) { _, newId in
                guard let newId else { return }
                guard !isSnapping else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard !self.isSnapping else { return }
                    self.mapVM.highlightedActivityId = newId

                    guard let activity = self.currentActivities
                        .first(where: { $0.id == newId }),
                          let location = activity.location
                    else { return }
                    self.mapVM.smoothAnimateToPin(to: location.coordinate)
                    self.mapVM.selectedLocation = location
                }
            }
            // Externe Änderung (Pin-Tap, Row-Tap) → Index syncen + scrollen
            .onChange(of: mapVM.highlightedActivityId) { _, newId in
                guard let newId,
                      let index = currentActivities.firstIndex(where: { $0.id == newId })
                else { return }
                guard !isSnapping else { return }
                currentIndex = index
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newId, anchor: .top)
                }
            }
            .onAppear {
                if let id = mapVM.highlightedActivityId {
                    if let index = currentActivities.firstIndex(where: { $0.id == id }) {
                        currentIndex = index
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(id, anchor: .top)
                    }
                }
            }
            // Nach Speichern → zur neuen Aktivität scrollen
            .onReceive(NotificationCenter.default.publisher(for: .scrollToActivity)) { notification in
                guard let id = notification.object as? Activity.ID else { return }
                if let index = currentActivities.firstIndex(where: { $0.id == id }) {
                    currentIndex = index
                }
                withAnimation(.easeInOut(duration: 0.4)) {
                    proxy.scrollTo(id, anchor: .top)
                }
                mapVM.highlightedActivityId = id
            }
        }
        .clipped()
        // Filter von außen (ChipBar, CategoryIconView-Tap) → Index syncen
        .onChange(of: filterVM.selectedCategoryId) { _, newId in
            currentIndex = 0
            if let newId {
                if let idx = categoryPages.firstIndex(where: { $0?.id == newId }),
                   idx != selectedPageIndex {
                    selectedPageIndex = idx
                }
            } else if selectedPageIndex != 0 {
                selectedPageIndex = 0
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
            mediumCountHeader
            Divider()
            contentScrollView
        }
    }

    @ViewBuilder
    private var mediumCountHeader: some View {
        let activities = currentActivities
        if !activities.isEmpty {
            let count = activities.count
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

    // MARK: Large Content (100 %)

    private var largeContent: some View {
        VStack(spacing: 0) {
            largeListHeader
            contentScrollView
        }
    }

    @ViewBuilder
    private var largeListHeader: some View {
        VStack(spacing: 0) {
            // Handle mit Drag-Gesture — Sheet von large auf medium ziehen
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(sheetDragGesture)

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

    // MARK: Category Swipe

    /// Wechselt zur nächsten Kategorie (Wischen nach links).
    /// Phase 1: aktuelle Liste über die volle Breite nach links schieben.
    /// Phase 2: neue Liste von rechts einfedern.
    private func swipeToNext() {
        let pages    = categoryPages
        let newIndex = min(selectedPageIndex + 1, pages.count - 1)
        guard newIndex != selectedPageIndex else { return }

        withAnimation(.easeIn(duration: 0.18)) {
            listOffset  = -300
            listOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            selectCategory(index: newIndex)
            listId     = UUID()
            listOffset = 300   // neue Liste startet rechts außerhalb
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                listOffset  = 0
                listOpacity = 1.0
            }
        }
    }

    /// Wechselt zur vorherigen Kategorie (Wischen nach rechts).
    private func swipeToPrevious() {
        let pages    = categoryPages
        let newIndex = max(selectedPageIndex - 1, 0)
        guard newIndex != selectedPageIndex else { return }

        withAnimation(.easeIn(duration: 0.18)) {
            listOffset  = 300
            listOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            selectCategory(index: newIndex)
            listId     = UUID()
            listOffset = -300  // neue Liste startet links außerhalb
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                listOffset  = 0
                listOpacity = 1.0
            }
        }
    }

    /// Setzt `selectedPageIndex` und aktualisiert den Filter — ohne eigene Animation.
    private func selectCategory(index: Int) {
        selectedPageIndex = index
        applyPageFilter(index: index)
    }

    private func applyPageFilter(index: Int) {
        let pages = categoryPages
        guard index < pages.count else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            if let category = pages[index] {
                filterVM.setFilter(categoryId: category.id)
            } else {
                filterVM.clearFilter()
            }
        }
        HapticManager.selectionChanged()
        NotificationCenter.default.post(
            name: .categoryFilterChanged,
            object: filterVM.selectedCategoryId
        )
    }

    // MARK: Year Separator

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
    /// Hervorgehobene Zeile zeigt farbigen Streifen links und rötlichen Hintergrund.
    @ViewBuilder
    private func activityRow(activity: Activity) -> some View {
        let isHighlighted = activity.id == mapVM.highlightedActivityId
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

            HStack(spacing: 8) {

                // ── Datum links ──────────────────────────────────
                VStack(alignment: .center, spacing: 0) {
                    Text(activity.dayString)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(activity.monthString)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 36)

                // ── Titel → Text → Location mitte ───────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    if let text = activity.text, !text.isEmpty {
                        Text(text)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    let poi          = activity.location?.locationName ?? ""
                    let city         = activity.location?.city ?? ""
                    let locationText = poi.isEmpty ? city : city.isEmpty ? poi : "\(poi) · \(city)"

                    if !locationText.isEmpty {
                        Text(locationText)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // ── Sterne oben, Icon darunter ───────────────────
                VStack(alignment: .trailing, spacing: 2) {

                    // Sterne ganz oben — Platzhalter wenn keine
                    if activity.starRating > 0 {
                        HStack(spacing: 2) {
                            ForEach(1...activity.starRating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color(hex: "#FFD700"))
                            }
                        }
                    } else {
                        Color.clear.frame(height: 9)
                    }

                    // Thumbnail links + Icon rechts
                    HStack(spacing: 6) {
                        if let photoData = activity.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 38, height: 38)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }

                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filterVM.setFilter(categoryId: activity.categoryId)
                            }
                            mapVM.highlightedActivityId = activity.id
                            if let location = activity.location {
                                mapVM.animateToPin(
                                    from: mapVM.selectedLocation,
                                    to: location,
                                    currentSpan: mapVM.region.span
                                )
                                mapVM.selectedLocation = location
                            }
                            HapticManager.selectionChanged()
                        } label: {
                            CategoryIconView(categoryId: activity.categoryId, size: 38)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .fixedSize()
            }
            .padding(.horizontal, 13)   // 16 - 3 (Streifen-Breite)
            .padding(.vertical, 6)
        }
        .background(isHighlighted ? Color(hex: "#E8593C").opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            // 1. Highlight setzen
            mapVM.highlightedActivityId = activity.id
            mapVM.selectedLocation      = activity.location

            // 2. Karte zentrieren + Zoom
            if let location = activity.location {
                mapVM.smoothAnimateToPin(to: location.coordinate)
                let currentSpan = mapVM.region.span
                let targetSpan  = currentSpan.latitudeDelta > 0.2
                    ? MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    : currentSpan
                mapVM.region = MKCoordinateRegion(
                    center: mapVM.adjustedCenter(
                        for: location.coordinate,
                        span: targetSpan,
                        sheetDetent: 0.45
                    ),
                    span: targetSpan
                )
            }

            // 3. Detail-Sheet öffnen
            selectedActivity = activity
        }
    }

    // MARK: Snap Helpers

    /// Aktualisiert `topRowId` und `topRowVisible` wenn die übergebene Row die oberste sichtbare ist.
    private func updateTopRow(frame: CGRect, activityId: Activity.ID) {
        guard !isSnapping else { return }
        let rowHeight = frame.height
        guard rowHeight > 0 else { return }
        let minY = frame.minY
        guard minY <= 0 && minY > -rowHeight else { return }
        let percent        = (rowHeight + minY) / rowHeight
        let idChanged      = topRowId != activityId
        let percentChanged = abs(topRowVisible - percent) > 0.1
        guard idChanged || percentChanged else { return }
        topRowId      = activityId
        topRowVisible = percent
    }

    /// Snappt zur Aktivität die nach einem Fling ganz oben sichtbar ist (via scrollPosition-Tracker).
    private func snapToCurrentPosition(proxy: ScrollViewProxy) {
        guard let topId = topRowId,
              let idx   = currentActivities.firstIndex(where: { $0.id == topId })
        else {
            // Fallback: scrollPosition
            guard let currentId = scrollPosition,
                  let fbIdx = currentActivities.firstIndex(where: { $0.id == currentId })
            else {
                snapTo(index: currentIndex, proxy: proxy)
                return
            }
            snapTo(index: fbIdx, proxy: proxy)
            return
        }

        let targetIndex: Int
        if topRowVisible >= 0.5 {
            targetIndex = idx
        } else {
            targetIndex = min(idx + 1, currentActivities.count - 1)
        }

        snapTo(index: targetIndex, proxy: proxy)
    }

    /// Scrollt zu einer Aktivität per Index und aktualisiert Map + Highlight.
    private func snapTo(index: Int, proxy: ScrollViewProxy) {
        guard index >= 0 && index < currentActivities.count else { return }

        let target   = currentActivities[index]
        currentIndex = index
        isSnapping   = true

        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(target.id, anchor: .top)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.mapVM.highlightedActivityId = target.id
            if let location = target.location {
                self.mapVM.smoothAnimateToPin(to: location.coordinate)
                self.mapVM.selectedLocation = location
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isSnapping = false
        }
    }

    // MARK: Helpers

    private func heightFor(_ detent: SheetDetent, _ screen: CGFloat) -> CGFloat {
        switch detent {
        case .small:  return screen * AppConstants.bottomSheetSmall
        case .medium: return screen * 0.45
        case .large:
            let topSafeArea = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.safeAreaInsets.top ?? 47
            return screen - topSafeArea - 8
        }
    }

    /// Karte nach Drag-Ende neu zentrieren.
    private func syncMapAfterDrag(detent: SheetDetent) {
        switch detent {
        case .small:
            mapVM.currentSheetDetent = AppConstants.bottomSheetSmall
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                guard let activity = mapVM.displayedActivities
                    .first(where: { $0.id == mapVM.highlightedActivityId }),
                      let location = activity.location else { return }
                let center = mapVM.adjustedCenter(
                    for: location.coordinate,
                    span: mapVM.region.span,
                    sheetDetent: AppConstants.bottomSheetSmall
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
}

// MARK: - Preview

#Preview("Permanent Bottom Sheet — medium") {
    let analytics       = AnalyticsManager()
    let mapVM           = MapViewModel(analytics: analytics)
    let filterVM        = FilterViewModel(analytics: analytics)
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
