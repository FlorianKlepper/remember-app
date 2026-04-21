// ActivityTracker2App.swift
// ActivityTracker2 — Remember
// App Entry Point — Dependency-Setup und ModelContainer-Konfiguration

import SwiftUI
import SwiftData
import TelemetryDeck

// MARK: - ActivityTracker2App

/// Entry Point der App. Erstellt alle Manager, ViewModels und den SwiftData-Container.
/// Alle Objekte werden per `.environment()` in die View-Hierarchie injiziert.
@main
struct ActivityTracker2App: App {

    // MARK: Manager

    private let locationManager:  LocationManager
    private let geocodeManager:   GeocodeManager
    private let analyticsManager: AnalyticsManager
    private let storeKitManager:  StoreKitManager
    // HapticManager ist ein stateless enum mit ausschließlich statischen Methoden
    // und wird direkt via HapticManager.selectionChanged() aufgerufen — keine Injection.
    private let languageManager:  LanguageManager

    // MARK: Settings

    private let userSettings: UserSettings

    // MARK: ViewModels

    private let activityViewModel:    ActivityViewModel
    private let mapViewModel:         MapViewModel
    private let filterViewModel:      FilterViewModel
    private let addActivityViewModel: AddActivityViewModel
    private let statsViewModel:       StatsViewModel
    private let onboardingViewModel:  OnboardingViewModel
    private let plusViewModel:        PlusViewModel

    // MARK: Persistenz

    private let modelContainer: ModelContainer

    // MARK: Init

    /// Initialisiert alle Abhängigkeiten in der korrekten Reihenfolge.
    /// `AnalyticsManager` wird zuerst erstellt, da `ActivityViewModel`
    /// und `PlusViewModel` ihn als Parameter benötigen.
    init() {
        // 0. TelemetryDeck — muss als erstes initialisiert werden
        TelemetryDeck.initialize(config: .init(appID: "DB2C7E9A-F056-413C-B648-A062D6E037A7"))

        // 1. Analytics zuerst — wird von mehreren ViewModels benötigt
        let analytics = AnalyticsManager()
        analyticsManager = analytics

        // 2. Restliche Manager
        locationManager  = LocationManager()
        geocodeManager   = GeocodeManager()
        storeKitManager  = StoreKitManager()
        languageManager  = LanguageManager()

        // 3. Settings
        userSettings = UserSettings()

        // 4. ViewModels — abhängige zuerst
        activityViewModel    = ActivityViewModel(analytics: analytics)
        plusViewModel        = PlusViewModel(analytics: analytics)
        mapViewModel         = MapViewModel(analytics: analytics)
        filterViewModel      = FilterViewModel(analytics: analytics)
        addActivityViewModel = AddActivityViewModel()
        statsViewModel       = StatsViewModel()
        onboardingViewModel  = OnboardingViewModel()

        // 5. SwiftData ModelContainer
        let schema = Schema([Activity.self, Location.self])

        if let container = try? ModelContainer(for: schema) {
            modelContainer = container
        } else if let fallback = try? ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        ) {
            // Persistenz nicht verfügbar — In-Memory-Fallback (kein Datenverlust-Schutz)
            modelContainer = fallback
        } else {
            // Dieser Pfad ist bei gültigem Schema nicht erreichbar
            fatalError("ModelContainer konnte nicht erstellt werden — Schema ungültig")
        }

        // 6. Debug: Sample-Daten einfügen wenn Store leer ist
        #if DEBUG
        PreviewDataHelper.insertSampleDataIfNeeded(context: modelContainer.mainContext)
        #endif
    }

    // MARK: State

    @State private var showWelcome: Bool = false

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            ZStack {
                if userSettings.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingScreen()
                }

                if showWelcome {
                    WelcomeOverlayView(isShowing: $showWelcome)
                        .zIndex(99999)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.4), value: showWelcome)
                }
            }
            .modelContainer(modelContainer)
            .environment(locationManager)
            .environment(geocodeManager)
            .environment(analyticsManager)
            .environment(storeKitManager)
            .environment(languageManager)
            .environment(userSettings)
            .environment(activityViewModel)
            .environment(mapViewModel)
            .environment(filterViewModel)
            .environment(addActivityViewModel)
            .environment(statsViewModel)
            .environment(onboardingViewModel)
            .environment(plusViewModel)
            .onAppear {
                analyticsManager.track(.appOpened)
                locationManager.startUpdating()
                #if DEBUG
                UserDefaults.standard.removeObject(forKey: "hasSeenWelcome")
                print("hasSeenWelcome: \(UserDefaults.standard.bool(forKey: "hasSeenWelcome"))")
                print("hasCompletedOnboarding: \(userSettings.hasCompletedOnboarding)")
                #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !UserDefaults.standard.bool(forKey: "hasSeenWelcome") {
                        showWelcome = true
                    }
                }
            }
            // App kommt aus dem Hintergrund (z.B. nach iOS Einstellungen) → Location neu prüfen
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification)
            ) { _ in
                locationManager.startUpdating()
            }
            .task {
                // Entitlements prüfen und beide Stores synchronisieren
                await storeKitManager.checkCurrentEntitlements(settings: userSettings)
            }
        }
    }
}
