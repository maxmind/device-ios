import Foundation

/// Represents an item in the shopping cart
struct CartItem: Identifiable {
    let id: UUID
    let shoe: Shoe
    let size: Double
    let color: String
    var quantity: Int

    init(
        id: UUID = UUID(),
        shoe: Shoe,
        size: Double,
        color: String,
        quantity: Int = 1
    ) {
        self.id = id
        self.shoe = shoe
        self.size = size
        self.color = color
        self.quantity = quantity
    }

    var totalPrice: Double {
        return shoe.price * Double(quantity)
    }
}
