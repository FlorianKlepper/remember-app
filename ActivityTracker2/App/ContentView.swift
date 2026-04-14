// ContentView.swift
// ActivityTracker2 — Remember
// Root-View nach dem Onboarding — 4-Tab-Navigation mit floating Tab Bar

import SwiftUI
import SwiftData

// MARK: - ContentView

/// Haupt-Navigation der App nach abgeschlossenem Onboarding.
/// Vier Tabs: Map · Liste · Plus · Statistik.
/// Floating Tab Bar — kein UITabBar, kein TabView.
/// Tab-Wechsel postet direkt NotificationCenter-Events → kein Loop-Risiko.
struct ContentView: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(FilterViewModel.self)    private var filterVM
    @Environment(\.modelContext)          private var modelContext

    // MARK: State

    @State private var selectedTab:  Int  = 0
    @State private var showAddFlow        = false
    /// Spiegelt den aktuellen Sheet-Zustand — steuert Karte/Liste-Highlighting.
    @State private var isSheetLarge: Bool = false

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Content je nach aktivem Tab ──────────────────────────
            Group {
                switch selectedTab {
                case 0, 1:
                    MapScreen(isListMode: selectedTab == 1)
                case 2:
                    PlusScreen()
                        .ignoresSafeArea()
                case 3:
                    StatsScreen()
                        .ignoresSafeArea()
                default:
                    MapScreen(isListMode: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // ── FloatingPlusButton — nur auf Map/Liste ────────────────
            if selectedTab <= 1 {
                FloatingPlusButton(action: { showAddFlow = true }, color: fabColor)
                    .padding(.trailing, 8)
                    .padding(.bottom, tabBarHeight + 4)
                    .zIndex(999)
            }

            // ── Floating Tab Bar ──────────────────────────────────────
            customTabBar
                .zIndex(100)
        }
        .onAppear {
            activityVM.fetchActivities(context: modelContext)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 3 { analyticsManager.track(.statsOpened) }
        }
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
                .presentationDetents([.large])
        }
        // Sheet-Zustand → Tab Bar Farbe + selectedTab sync
        .onReceive(NotificationCenter.default.publisher(for: .sheetDidChange)) { notification in
            print("ContentView empfängt sheetDidChange: \(notification.object ?? "nil")")
            guard let isLarge = notification.object as? Bool else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                isSheetLarge = isLarge
                print("isSheetLarge = \(isLarge)")
            }
            if isLarge && selectedTab != 1 {
                selectedTab = 1
            } else if !isLarge && selectedTab == 1 {
                selectedTab = 0
            }
        }
    }

    // MARK: Custom Floating Tab Bar
    // Inline-Buttons mit direktem Zugriff auf isSheetLarge + selectedTab —
    // kein Funktionsaufruf, damit SwiftUI reaktiv auf State-Änderungen rendert.

    private var customTabBar: some View {
        HStack(spacing: 0) {

            // ── Karte — blau wenn Sheet NICHT large ─────────────────
            Button {
                selectedTab = 0
                NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                HapticManager.selectionChanged()
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "map")
                        .font(.system(size: 22))
                    Text(LocalizedStringKey("tab.map"))
                        .font(.system(size: 10))
                }
                .foregroundStyle(
                    !isSheetLarge && selectedTab <= 1 ? Color.blue : Color(.systemGray2)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)

            // ── Liste — blau wenn Sheet large ───────────────────────
            Button {
                selectedTab = 1
                NotificationCenter.default.post(name: .setSheetLarge, object: nil)
                HapticManager.selectionChanged()
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 22))
                    Text(LocalizedStringKey("tab.list"))
                        .font(.system(size: 10))
                }
                .foregroundStyle(
                    isSheetLarge ? Color.blue : Color(.systemGray2)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)

            // ── Plus — Icon immer gold ───────────────────────────────
            Button {
                selectedTab = 2
                HapticManager.selectionChanged()
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: "#FFD700"))
                    Text(LocalizedStringKey("tab.plus"))
                        .font(.system(size: 10))
                        .foregroundStyle(
                            selectedTab == 2 ? Color.blue : Color(.systemGray2)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)

            // ── Statistik ────────────────────────────────────────────
            Button {
                selectedTab = 3
                HapticManager.selectionChanged()
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 22))
                    Text(LocalizedStringKey("tab.stats"))
                        .font(.system(size: 10))
                }
                .foregroundStyle(
                    selectedTab == 3 ? Color.blue : Color(.systemGray2)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 49)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: Private Helpers

    /// FloatingPlusButton-Farbe: aktive Kategorie-Farbe wenn Filter gesetzt, sonst systemGray2.
    private var fabColor: Color {
        guard let categoryId = filterVM.selectedCategoryId,
              let category = (Category.mvpCategories + Category.plusCategories)
                  .first(where: { $0.id == categoryId })
        else { return Color(.systemGray2) }
        return Color(hex: category.colorHex)
    }

    /// Höhe der Tab Bar inkl. Safe Area — für FAB-Positionierung.
    private var tabBarHeight: CGFloat {
        let safeArea = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 34
        return 49 + safeArea + 4
    }
}

// MARK: - Preview

#Preview("Content View") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel()
    let filterVM = FilterViewModel()
    let statsVM = StatsViewModel()
    let plusVM = PlusViewModel(analytics: analytics)
    let settings = UserSettings()
    let storeKit = StoreKitManager()

    activityVM.activities = Activity.samples
    statsVM.compute(from: Activity.samples)

    return ContentView()
        .environment(activityVM)
        .environment(mapVM)
        .environment(filterVM)
        .environment(statsVM)
        .environment(plusVM)
        .environment(settings)
        .environment(storeKit)
        .environment(analytics)
}
