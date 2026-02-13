import Foundation
import SwiftUI

/// Main view model for the shoe store app
@MainActor
class ShoeStoreViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var shoes: [Shoe] = Shoe.sampleShoes
    @Published var cartItems: [CartItem] = []
    @Published var showingCart: Bool = false
    @Published var showingCheckout: Bool = false

    // Fraud detection
    @Published var fraudService = FraudDetectionService()
    @Published var isAnalyzingFraud: Bool = false
    @Published var fraudAnalysisComplete: Bool = false

    // MARK: - Computed Properties

    var cartTotal: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }

    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var cartIsEmpty: Bool {
        cartItems.isEmpty
    }

    // MARK: - Cart Management

    /// Adds an item to the cart
    func addToCart(shoe: Shoe, size: Double, color: String) {
        // Check if this exact item already exists in cart
        if let index = cartItems.firstIndex(where: {
            $0.shoe.id == shoe.id && $0.size == size && $0.color == color
        }) {
            // Increment quantity
            cartItems[index].quantity += 1
        } else {
            // Add new item
            let newItem = CartItem(shoe: shoe, size: size, color: color)
            cartItems.append(newItem)
        }
    }

    /// Updates the quantity of a cart item
    func updateQuantity(for item: CartItem, quantity: Int) {
        guard quantity > 0 else {
            removeFromCart(item: item)
            return
        }

        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity = quantity
        }
    }

    /// Removes an item from the cart
    func removeFromCart(item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    /// Clears all items from the cart
    func clearCart() {
        cartItems.removeAll()
        fraudAnalysisComplete = false
    }

    // MARK: - Fraud Detection

    /// Analyzes the current cart for fraud risk before checkout
    func analyzeCartForFraud() async {
        isAnalyzingFraud = true
        fraudAnalysisComplete = false

        let riskLevel = await fraudService.analyzeTransaction(
            amount: cartTotal,
            items: cartItemCount
        )

        isAnalyzingFraud = false
        fraudAnalysisComplete = true

        // In a real app, you might block high-risk transactions
        // or require additional verification
    }

    // MARK: - Checkout

    /// Initiates the checkout process
    func proceedToCheckout() {
        showingCheckout = true
    }

    /// Completes the purchase
    func completePurchase() async throws {
        // In a real app, this would:
        // 1. Send order to your backend
        // 2. Process payment
        // 3. Include device ID and fraud assessment
        // 4. Handle response

        // Simulate processing delay
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Clear cart on success
        clearCart()
        showingCheckout = false
        showingCart = false
    }
}
