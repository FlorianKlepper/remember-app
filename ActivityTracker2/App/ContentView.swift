// ContentView.swift
// ActivityTracker2 — Remember
// Root-View nach dem Onboarding — 4-Tab-Navigation

import SwiftUI
import SwiftData

// MARK: - ContentView

/// Haupt-Navigation der App nach abgeschlossenem Onboarding.
/// Vier Tabs: Map (Startscreen) · Liste · Statistik · Plus.
struct ContentView: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(\.modelContext)          private var modelContext

    // MARK: State

    @State private var selectedTab: Int = 0
    @State private var showAddFlow    = false

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // ── Tab-Navigation ───────────────────────────────────────
            TabView(selection: $selectedTab) {

                // ── Tab 0: Karte (Startscreen) ──────────────────────
                MapScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.map"), systemImage: "map")
                    }
                    .tag(0)

                // ── Tab 1: Liste ─────────────────────────────────────
                ListScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.list"), systemImage: "list.bullet")
                    }
                    .tag(1)

                // ── Tab 2: Plus / Paywall ────────────────────────────
                PlusScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.plus"), systemImage: "crown.fill")
                    }
                    .tag(2)

                // ── Tab 3: Statistik ──────────────────────────────────
                StatsScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.stats"), systemImage: "chart.dots.scatter")
                    }
                    .tag(3)
            }
            .onAppear {
                activityVM.fetchActivities(context: modelContext)
            }
            .onChange(of: selectedTab) { _, newTab in
                if newTab == 3 {
                    analyticsManager.track(.statsOpened)
                }
            }

            // ── Globaler FloatingPlusButton — auf allen Tabs ─────────
            FloatingPlusButton {
                showAddFlow = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, tabBarHeight + 16)
        }
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
                .presentationDetents([.large])
        }
    }

    // MARK: Private

    /// Standard Tab-Bar-Höhe (49 pt) plus Safe-Area-Inset (z.B. 34 pt auf iPhone mit Home Indicator).
    private var tabBarHeight: CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let bottomInset = scene?.windows.first?.safeAreaInsets.bottom ?? 0
        return 49 + bottomInset
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
