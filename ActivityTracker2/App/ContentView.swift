// ContentView.swift
// ActivityTracker2 — Remember
// Root-View nach dem Onboarding — 4-Tab-Navigation mit floating Tab Bar

import SwiftUI
import SwiftData

// MARK: - TabItemView

/// Einzelner Tab-Button mit App-Store-Bounce-Animation:
/// Icon springt auf 1.4x → Bubble erscheint → Bubble verschwindet.
private struct TabItemView: View {

    let icon:     String
    let labelKey: LocalizedStringKey
    let isActive: Bool
    let color:    Color
    let action:   () -> Void

    @State private var scale:         CGFloat = 1.0
    @State private var bubbleOpacity: Double  = 0.0
    @State private var bubbleScale:   CGFloat = 0.4

    var body: some View {
        Button {
            action()
            animate()
        } label: {
            ZStack {
                // ── Farbiger Bubble ──────────────────────────────
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 44, height: 44)
                    .scaleEffect(bubbleScale)
                    .opacity(bubbleOpacity)

                // ── Icon + Label ─────────────────────────────────
                VStack(spacing: 3) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .scaleEffect(scale)
                    Text(labelKey)
                        .font(.system(size: 10))
                }
                .foregroundStyle(isActive ? color : Color(.systemGray2))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private func animate() {
        // 1. Icon auf 1.4x zoomen
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scale = 1.4
        }
        // 2. Bubble einblenden
        withAnimation(.easeOut(duration: 0.15)) {
            bubbleOpacity = 1.0
            bubbleScale   = 1.0
        }
        // 3. Icon zurück auf 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
        // 4. Bubble ausblenden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeIn(duration: 0.2)) {
                bubbleOpacity = 0.0
                bubbleScale   = 0.4
            }
        }
    }
}

// MARK: - AppTabBar

/// Separate View damit SwiftUI @Binding-Änderungen zuverlässig trackt.
struct AppTabBar: View {

    @Binding var isSheetLarge: Bool
    @Binding var selectedTab:  Int
    var onKarte:     () -> Void
    var onListe:     () -> Void
    var onPlus:      () -> Void
    var onStatistik: () -> Void

    private var karteActive:    Bool { !isSheetLarge && selectedTab <= 1 }
    private var listeActive:    Bool { isSheetLarge }
    private var plusActive:     Bool { selectedTab == 2 }
    private var statistikActive: Bool { selectedTab == 3 }

    var body: some View {
        HStack(spacing: 0) {

            TabItemView(icon: "map",                  labelKey: "tab.map",   isActive: karteActive,    color: .blue,                      action: onKarte)
            TabItemView(icon: "list.bullet",          labelKey: "tab.list",  isActive: listeActive,    color: .blue,                      action: onListe)
            TabItemView(icon: "crown.fill",           labelKey: "tab.plus",  isActive: plusActive,     color: Color(hex: "#FFD700"),       action: onPlus)
            TabItemView(icon: "rectangle.3.group.fill", labelKey: "tab.stats", isActive: statistikActive, color: .blue,                   action: onStatistik)
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
    @Environment(StoreKitManager.self)    private var storeKitManager
    @Environment(\.modelContext)          private var modelContext

    @Query private var activities: [Activity]

    // MARK: State

    @State private var selectedTab:    Int  = 0
    @State private var showAddFlow          = false
    @State private var showLimitReached     = false
    @State private var showLimitWarning     = false
    @State private var showPlus             = false
    @State private var isSheetLarge:   Bool = false

    @State private var showWelcome: Bool = false

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
                FloatingPlusButton(
                    action: {
                        if hasReachedLimit {
                            showLimitReached = true
                        } else {
                            showAddFlow = true
                        }
                    },
                    color: fabColor
                )
                    .padding(.trailing, 20)
                    .padding(.bottom, 110)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .zIndex(999)
                    .allowsHitTesting(true)
            }

            // ━━━ 3. Welcome Overlay — nur beim allerersten Start ━━━
            if showWelcome {
                WelcomeOverlayView(isShowing: $showWelcome)
                    .zIndex(99999)
                    .transition(.opacity)
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
            activityVM.normalizeExistingLocations(context: modelContext)
            #if DEBUG
            UserDefaults.standard.removeObject(forKey: "hasSeenWelcome")
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            #endif
        }
        .sheet(isPresented: $showAddFlow) {
            AddActivityCategoryScreen()
        }
        .sheet(isPresented: $showLimitReached) {
            LimitReachedSheet(isShowing: $showLimitReached)
        }
        .sheet(isPresented: $showPlus) {
            PlusScreen(source: "limit_80_warning")
        }
        .sheet(isPresented: $showLimitWarning) {
            VStack(spacing: 20) {

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                    .padding(.top, 8)

                Text("Fast voll!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Du hast 80 von 100 kostenlosen Aktivitäten verwendet.\nNoch 20 verfügbar.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("80 / 100")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("80%")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    ProgressView(value: 80, total: 100)
                        .tint(.orange)
                }
                .padding(.horizontal, 32)

                Button {
                    showLimitWarning = false
                    UserDefaults.standard.set(true, forKey: "hasSeenLimit80Warning")
                    showPlus = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color(hex: "#FFD700"))
                        Text("Jetzt upgraden — 4,99€")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#E8593C"))
                    )
                }
                .padding(.horizontal, 24)

                Button {
                    showLimitWarning = false
                    UserDefaults.standard.set(true, forKey: "hasSeenLimit80Warning")
                } label: {
                    Text("Später")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 32)
            }
            .presentationDetents([.medium])
        }
        .onChange(of: activities.count) { _, count in
            if count == 80 &&
               !isPlusUser &&
               !UserDefaults.standard.bool(forKey: "hasSeenLimit80Warning") {
                showLimitWarning = true
            }
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
        // Add-Flow komplett schließen (aus AddActivityTextScreen)
        .onReceive(NotificationCenter.default.publisher(for: .dismissAddActivity)) { _ in
            showAddFlow = false
        }
    }

    // MARK: Private Helpers

    private var isPlusUser: Bool {
        storeKitManager.isPlusActive || userSettings.subscriptionStatus == .plus
    }

    private var hasReachedLimit: Bool {
        !isPlusUser && activities.count >= AppConstants.freeActivityLimit
    }

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
