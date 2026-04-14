// ContentView.swift
// ActivityTracker2 — Remember
// Root-View nach dem Onboarding — 4-Tab-Navigation

import SwiftUI
import SwiftData

// MARK: - ContentView

/// Haupt-Navigation der App nach abgeschlossenem Onboarding.
/// Vier Tabs: Map · Liste · Plus · Statistik.
/// Goldene Krone wird via static init()-Pfad SOFORT beim ersten Render gesetzt —
/// kein asyncAfter-Delay, kein sichtbares Fade-in.
struct ContentView: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(FilterViewModel.self)    private var filterVM
    @Environment(\.modelContext)          private var modelContext

    // MARK: State

    @State private var selectedTab: Int = 0
    @State private var showAddFlow    = false

    // MARK: Init

    init() {
        // Appearance global setzen BEVOR die Tab Bar gerendert wird
        Self.applyTabBarAppearance()
        // Krone im nächsten Run Loop setzen (Tab Bar existiert dann)
        DispatchQueue.main.async {
            Self.setGoldenCrown()
        }
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // ── Standard TabView — Floating Bar bleibt erhalten ──────
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

                // ── Tab 2: Plus / Paywall ─────────────────────────────
                PlusScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.plus"), systemImage: "crown.fill")
                    }
                    .tag(2)

                // ── Tab 3: Statistik ──────────────────────────────────
                StatsScreen()
                    .tabItem {
                        Label(LocalizedStringKey("tab.stats"), systemImage: "rectangle.3.group.fill")
                    }
                    .tag(3)
            }
            .onAppear {
                activityVM.fetchActivities(context: modelContext)
            }
            .onChange(of: selectedTab) { _, newTab in
                if newTab == 3 { analyticsManager.track(.statsOpened) }
                // Krone nach Tab-Wechsel direkt im nächsten Run Loop erneuern
                DispatchQueue.main.async {
                    Self.setGoldenCrown()
                }
                HapticManager.selectionChanged()
            }

            // ── FloatingPlusButton — fix über Tab Bar, immer sichtbar ──
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingPlusButton(action: { showAddFlow = true }, color: fabColor)
                        .padding(.trailing, 24)
                        .padding(.bottom, tabBarHeight + 12)
                }
            }
            .zIndex(999)
        }
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
                .presentationDetents([.large])
        }
    }

    // MARK: Static Tab Bar Helpers

    /// Setzt UITabBarAppearance global — muss vor dem ersten Render laufen.
    static func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        appearance.backgroundColor  = UIColor.systemBackground.withAlphaComponent(0.8)

        let normalAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray2]
        appearance.stackedLayoutAppearance.normal.iconColor             = .systemGray2
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = normalAttr
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)

        let selectedAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.selected.iconColor            = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes  = selectedAttr
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)

        UITabBar.appearance().isTranslucent        = true
        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    /// Findet alle UITabBars rekursiv und setzt Krone (Index 2) auf Gold.
    /// Kein asyncAfter — wird im nächsten Run Loop nach dem Render aufgerufen.
    static func setGoldenCrown() {
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        let goldImage = UIImage(systemName: "crown.fill")?.withTintColor(gold, renderingMode: .alwaysOriginal)

        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { findAndGoldTabBar(in: $0, goldImage: goldImage) }
    }

    /// Durchsucht die View-Hierarchie rekursiv nach UITabBar-Instanzen
    /// und setzt Item 2 auf das goldene Kronen-Image.
    static func findAndGoldTabBar(in view: UIView, goldImage: UIImage?) {
        if let tabBar = view as? UITabBar {
            guard let item = tabBar.items?[safe: 2] else { return }
            item.image         = goldImage
            item.selectedImage = UIImage(systemName: "crown.fill")?
                .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            return
        }
        view.subviews.forEach { findAndGoldTabBar(in: $0, goldImage: goldImage) }
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

    /// Standard Tab-Bar-Höhe (49 pt) plus Safe-Area-Inset.
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
