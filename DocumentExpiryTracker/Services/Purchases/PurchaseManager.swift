import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.documentexpirytracker.pro.lifetime"
    static let defaultsKey = "isProUnlocked"

    @Published private(set) var isProUnlocked: Bool
    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var lastError: String?

    private let defaults: UserDefaults
    let isMockMode: Bool

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let arguments = ProcessInfo.processInfo.arguments
        self.isMockMode = arguments.contains("UITEST_MOCK_PRO_PURCHASES")
        self.isProUnlocked = defaults.bool(forKey: Self.defaultsKey) || arguments.contains("UITEST_FORCE_PRO")

        if arguments.contains("UITEST_FORCE_FREE") {
            self.isProUnlocked = false
            defaults.set(false, forKey: Self.defaultsKey)
        }
    }

    var priceLabel: String {
        product?.displayPrice ?? "$4.99"
    }

    func loadProduct() async {
        guard !isMockMode else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            product = try await Product.products(for: [Self.productID]).first
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        if isMockMode {
            persist(isProUnlocked)
            return
        }

        var unlocked = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == Self.productID {
                unlocked = true
            }
        }
        persist(unlocked)
    }

    func purchase() async -> Bool {
        if isMockMode {
            persist(true)
            return true
        }

        if product == nil {
            await loadProduct()
        }
        guard let product else {
            lastError = "Unable to load the Pro product right now."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    lastError = "Purchase could not be verified."
                    return false
                }
                await transaction.finish()
                persist(true)
                return true
            case .pending:
                lastError = "Purchase is pending approval."
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func restore() async -> Bool {
        if isMockMode {
            persist(true)
            return true
        }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return isProUnlocked
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func persist(_ unlocked: Bool) {
        isProUnlocked = unlocked
        defaults.set(unlocked, forKey: Self.defaultsKey)
    }
}
