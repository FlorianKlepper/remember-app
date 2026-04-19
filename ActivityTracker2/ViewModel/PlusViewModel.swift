// PlusViewModel.swift
// ActivityTracker2 — Remember
// Steuert den Plus-Kauf-Flow via StoreKit 2

import Foundation
import StoreKit

// MARK: - PlusViewModel

/// Verwaltet den Plus-Kaufprozess und stellt den State für den Plus-Screen bereit.
@Observable
@MainActor
final class PlusViewModel {

    // MARK: Properties

    /// `true` während ein Kaufvorgang läuft — sperrt den Kauf-Button.
    var isPurchasing: Bool = false

    /// Fehlermeldung für den User, falls ein Kauf oder Restore fehlschlägt.
    var errorMessage: String? = nil

    /// Das geladene Plus-Produkt aus dem App Store. `nil` bis `loadProducts()` abgeschlossen.
    var plusProduct: Product? = nil

    // MARK: Private

    private let analytics: AnalyticsManager

    // MARK: Init

    /// - Parameter analytics: Für `purchaseSuccess`-Event-Tracking nach erfolgreichem Kauf.
    init(analytics: AnalyticsManager) {
        self.analytics = analytics
    }
}

// MARK: - Produkte laden

extension PlusViewModel {

    /// Lädt das Plus-Produkt via `StoreKitManager` und spiegelt es lokal.
    /// - Parameter manager: Der App-weite `StoreKitManager`.
    func loadProducts(from manager: StoreKitManager) async {
        await manager.loadProducts()
        plusProduct = manager.plusProduct
    }
}

// MARK: - Kauf

extension PlusViewModel {

    /// Führt den Plus-Einmalkauf durch.
    /// - Setzt `isPurchasing` während des Vorgangs.
    /// - Bei Erfolg: `settings.subscriptionStatus = .plus` + Analytics-Event.
    /// - Bei Fehler: `errorMessage` wird befüllt.
    /// - Parameters:
    ///   - manager: Der App-weite `StoreKitManager`.
    ///   - settings: Globales `UserSettings`-Objekt für Subscription-Update.
    func purchasePlus(manager: StoreKitManager, settings: UserSettings) async {
        guard let product = plusProduct else {
            errorMessage = String(
                localized: "plus.error.no.product",
                defaultValue: "Produkt nicht verfügbar. Bitte versuche es später erneut."
            )
            return
        }

        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let success = try await manager.purchase(product, settings: settings)
            if success {
                analytics.track(.plusPurchased)
            }
        } catch let appError as AppError {
            errorMessage = appError.errorDescription
        } catch {
            errorMessage = AppError.storeKitError(error).errorDescription
        }
    }

    /// Stellt frühere Käufe wieder her.
    /// Aktualisiert `settings.subscriptionStatus` wenn ein aktiver Plus-Kauf gefunden wird.
    /// - Throws: `AppError.storeKitError` bei Netzwerk- oder Store-Fehlern.
    func restorePurchases(manager: StoreKitManager, settings: UserSettings) async throws {
        try await manager.restorePurchases(settings: settings)
    }
}
