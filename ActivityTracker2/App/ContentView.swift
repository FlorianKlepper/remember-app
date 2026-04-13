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

    // MARK: Body

    var body: some View {
        TabView(selection: $selectedTab) {

            // ── Tab 0: Karte (Startscreen) ──────────────────────────
            MapScreen()
                .tabItem {
                    Label(LocalizedStringKey("tab.map"), systemImage: "map")
                }
                .tag(0)

            // ── Tab 1: Liste ────────────────────────────────────────
            ListScreen()
                .tabItem {
                    Label(LocalizedStringKey("tab.list"), systemImage: "list.bullet")
                }
                .tag(1)

            // ── Tab 2: Statistik ────────────────────────────────────
            StatsScreen()
                .tabItem {
                    Label(LocalizedStringKey("tab.stats"), systemImage: "chart.bar.fill")
                }
                .tag(2)

            // ── Tab 3: Plus / Paywall ───────────────────────────────
            PlusScreen()
                .tabItem {
                    Label(LocalizedStringKey("tab.plus"), systemImage: "star.fill")
                }
                .tag(3)
        }
        .onAppear {
            // Initialer Datenabruf beim ersten Erscheinen der App
            activityVM.fetchActivities(context: modelContext)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 2 {
                analyticsManager.track(.statsOpened)
            }
        }
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
