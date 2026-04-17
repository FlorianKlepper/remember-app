// StoreKitManager.swift
// ActivityTracker2 — Remember
// In-App-Kauf via StoreKit 2 — Einmalzahlung für Plus

import Foundation
import StoreKit

// MARK: - StoreKitManager

/// Verwaltet den Plus-Einmalkauf via StoreKit 2.
/// Startet beim Init einen unstrukturierten Task zum Abhören von `Transaction.updates`,
/// um Transaktionen aus dem App Store (z.B. Family Sharing, Refunds) sofort zu verarbeiten.
@Observable
@MainActor
final class StoreKitManager {

    // MARK: Öffentliche Properties

    /// Geladenes Plus-Produkt aus dem App Store. `nil` bis `loadProducts()` abgeschlossen.
    var plusProduct: Product?

    /// `true` wenn der User einen verifizierten Plus-Kauf besitzt.
    var isPlusActive: Bool = false

    // MARK: Init

    init() {
        // Unstrukturierter Task: läuft für den gesamten App-Lifecycle
        Task {
            await listenForTransactions()
        }
        Task {
            await loadProducts()
            await checkCurrentEntitlements()
        }
    }
}

// MARK: - Öffentliche Methoden

extension StoreKitManager {

    /// Lädt verfügbare Produkte vom App Store.
    /// Befüllt `plusProduct` bei Erfolg. Fehler werden still ignoriert
    /// (kein Produkt = kein Plus-Angebot sichtbar).
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [AppConstants.plusProductId])
            plusProduct = products.first
        } catch {
            // Kein Produkt verfügbar (z.B. Simulator ohne StoreKit-Konfiguration)
            plusProduct = nil
        }
    }

    /// Startet den Kaufvorgang für ein Produkt.
    /// - Parameter product: Das zu kaufende `Product` (muss `plusProduct` sein).
    /// - Throws: `AppError.storeKitError` bei Kauffehlern.
    /// - Returns: `true` bei verifiziertem Kauf, `false` bei Abbruch oder Pending.
    func purchase(_ product: Product) async throws -> Bool {
        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            throw AppError.storeKitError(error)
        }

        switch result {
        case .success(let verification):
            return await handleVerification(verification)
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    /// Stellt frühere Käufe wieder her via `AppStore.sync()` und synchronisiert UserSettings.
    /// - Parameter settings: `UserSettings`-Objekt — wird bei aktivem Plus-Kauf auf `.plus` gesetzt.
    /// - Throws: `AppError.storeKitError` bei Netzwerk- oder Store-Fehlern.
    func restorePurchases(settings: UserSettings) async throws {
        do {
            try await AppStore.sync()
        } catch {
            throw AppError.storeKitError(error)
        }
        await checkCurrentEntitlements(settings: settings)
    }

    /// Prüft aktuelle Entitlements beim App-Start und nach `restorePurchases()`.
    /// Synchronisiert `isPlusActive` und optional `settings.subscriptionStatus`.
    /// - Parameter settings: Wenn übergeben, wird `subscriptionStatus` bei aktivem Plus auf `.plus` gesetzt.
    func checkCurrentEntitlements(settings: UserSettings? = nil) async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == AppConstants.plusProductId {
                isPlusActive = true
                settings?.subscriptionStatus = .plus
                return
            }
        }
    }

    /// Hört auf `Transaction.updates` — verarbeitet neue, erneuerte und widerrufene Käufe.
    /// Läuft als unstrukturierter Task für den gesamten App-Lifecycle.
    func listenForTransactions() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                if transaction.productID == AppConstants.plusProductId {
                    // Revocation-Check: `revocationDate` gesetzt = Kauf widerrufen
                    isPlusActive = transaction.revocationDate == nil
                }
                await transaction.finish()
            case .unverified:
                // Unverified Transaktionen werden ignoriert
                break
            }
        }
    }

    /// Verarbeitet ein `VerificationResult` und setzt `isPlusActive` bei Erfolg.
    func handleVerification(_ verification: VerificationResult<Transaction>) async -> Bool {
        switch verification {
        case .verified(let transaction):
            isPlusActive = true
            await transaction.finish()
            return true
        case .unverified:
            return false
        }
    }
}
