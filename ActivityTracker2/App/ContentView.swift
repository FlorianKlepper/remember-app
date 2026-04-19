// ContentView.swift
// ActivityTracker2 — Remember
// Root-View nach dem Onboarding — 4-Tab-Navigation mit floating Tab Bar

import SwiftUI
import SwiftData

// MARK: - AppTabBar

/// Separate View damit SwiftUI @Binding-Änderungen zuverlässig trackt.
struct AppTabBar: View {

    @Binding var isSheetLarge: Bool
    @Binding var selectedTab:  Int
    var onKarte:     () -> Void
    var onListe:     () -> Void
    var onPlus:      () -> Void
    var onStatistik: () -> Void

    var body: some View {
        HStack(spacing: 0) {

            // Karte
            Button(action: onKarte) {
                VStack(spacing: 3) {
                    Image(systemName: "map")
                        .font(.system(size: 22))
                    Text(LocalizedStringKey("tab.map"))
                        .font(.system(size: 10))
                }
                .foregroundStyle(
                    (!isSheetLarge && selectedTab <= 1) ? Color.blue : Color(.systemGray2)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
            .buttonStyle(.plain)

            // Liste
            Button(action: onListe) {
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
                .padding(.top, 10)
            }
            .buttonStyle(.plain)

            // Plus — Icon immer gold
            Button(action: onPlus) {
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
                .padding(.top, 10)
            }
            .buttonStyle(.plain)

            // Statistik
            Button(action: onStatistik) {
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
                .padding(.top, 10)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 62)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.systemGray5).opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - ContentView

/// Haupt-Navigation der App nach abgeschlossenem Onboarding.
/// AppTabBar als separate View mit @Binding — garantiert reaktives Re-Rendering.
struct ContentView: View {

    // MARK: Environment

    @Environment(ActivityViewModel.self)  private var activityVM
    @Environment(AnalyticsManager.self)   private var analyticsManager
    @Environment(FilterViewModel.self)    private var filterVM
    @Environment(MapViewModel.self)       private var mapVM
    @Environment(UserSettings.self)       private var userSettings
    @Environment(\.modelContext)          private var modelContext

    // MARK: State

    @State private var selectedTab:  Int  = 0
    @State private var showAddFlow        = false
    @State private var isSheetLarge: Bool = false

    /// Nur `true` wenn der User den Overlay noch nie gesehen hat.
    @State private var showWelcome: Bool =
        !UserDefaults.standard.bool(forKey: "hasSeenWelcome")

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {

            // ━━━ 1. Content — unterste Ebene ━━━
            switch selectedTab {
            case 0, 1:
                MapScreen(isListMode: selectedTab == 1)
                    .ignoresSafeArea()
            case 2:
                PlusScreen()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case 3:
                StatsScreen()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                MapScreen(isListMode: false)
                    .ignoresSafeArea()
            }

            // ━━━ 2. FloatingPlusButton — nur auf Map/Liste ━━━
            if selectedTab == 0 || selectedTab == 1 {
                FloatingPlusButton(action: { showAddFlow = true }, color: fabColor)
                    .padding(.trailing, 20)
                    .padding(.bottom, 110)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .zIndex(999)
                    .allowsHitTesting(true)
            }

            // ━━━ 3. Welcome Overlay — nur beim allerersten Start ━━━
            if showWelcome
                && userSettings.hasCompletedOnboarding
                && activityVM.activities.isEmpty {
                WelcomeOverlayView(isShowing: $showWelcome)
                    .zIndex(99999)
            }

            // ━━━ 4. Tab Bar — oberste Ebene ━━━
            AppTabBar(
                isSheetLarge: $isSheetLarge,
                selectedTab:  $selectedTab,
                onKarte: {
                    isSheetLarge = false
                    selectedTab = 0
                    mapVM.currentSheetDetent = 0.15
                    mapVM.centerOnNewest(activities: activityVM.activities)
                    NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                    HapticManager.selectionChanged()
                },
                onListe: {
                    isSheetLarge = true
                    selectedTab = 1
                    NotificationCenter.default.post(name: .setSheetLarge, object: nil)
                    HapticManager.selectionChanged()
                },
                onPlus: {
                    isSheetLarge = false
                    selectedTab = 2
                    NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                    HapticManager.selectionChanged()
                },
                onStatistik: {
                    isSheetLarge = false
                    selectedTab = 3
                    NotificationCenter.default.post(name: .setSheetSmall, object: nil)
                    HapticManager.selectionChanged()
                }
            )
            .zIndex(9999)
            .allowsHitTesting(true)
        }
        .animation(.easeInOut(duration: 0.3), value: showWelcome)
        .onAppear {
            activityVM.fetchActivities(context: modelContext)
        }
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
        }
        // Sheet-Drag → isSheetLarge + Tab Bar Farbe sync
        .onReceive(NotificationCenter.default.publisher(for: .sheetBecameLarge)) { _ in
            isSheetLarge = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .sheetBecameSmall)) { _ in
            isSheetLarge = false
        }
        // Nach Speichern → zurück auf Karte (Tab 0), Sheet auf medium
        .onReceive(NotificationCenter.default.publisher(for: .setSheetMedium)) { _ in
            isSheetLarge = false
            selectedTab = 0
        }
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

}

// MARK: - Preview

#Preview("Content View") {
    let analytics = AnalyticsManager()
    let activityVM = ActivityViewModel(analytics: analytics)
    let mapVM = MapViewModel(analytics: analytics)
    let filterVM = FilterViewModel(analytics: analytics)
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
