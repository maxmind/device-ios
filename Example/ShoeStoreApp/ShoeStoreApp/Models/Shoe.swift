import Foundation

/// Represents a shoe product in the store
struct Shoe: Identifiable, Codable {
    let id: UUID
    let name: String
    let brand: String
    let price: Double
    let description: String
    let imageName: String
    let sizes: [Double]
    let colors: [String]

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        price: Double,
        description: String,
        imageName: String,
        sizes: [Double],
        colors: [String]
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.price = price
        self.description = description
        self.imageName = imageName
        self.sizes = sizes
        self.colors = colors
    }
}

// MARK: - Sample Data

extension Shoe {
    static let sampleShoes: [Shoe] = [
        Shoe(
            name: "Air Runner Pro",
            brand: "SwiftKicks",
            price: 129.99,
            description: "Premium running shoes with advanced cushioning technology and breathable mesh upper.",
            imageName: "shoe1",
            sizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0],
            colors: ["Black", "White", "Blue", "Red"]
        ),
        Shoe(
            name: "Urban Stride",
            brand: "CityWalk",
            price: 89.99,
            description: "Casual everyday sneakers perfect for urban exploration. Comfortable and stylish.",
            imageName: "shoe2",
            sizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0],
            colors: ["Gray", "Navy", "Olive"]
        ),
        Shoe(
            name: "Trail Blazer X",
            brand: "MountainGear",
            price: 159.99,
            description: "Rugged trail running shoes with superior grip and all-terrain durability.",
            imageName: "shoe3",
            sizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0, 12.5, 13.0],
            colors: ["Brown", "Forest Green", "Black"]
        ),
        Shoe(
            name: "Speed Racer Elite",
            brand: "SwiftKicks",
            price: 179.99,
            description: "Competition-grade running shoes engineered for maximum speed and performance.",
            imageName: "shoe4",
            sizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0],
            colors: ["Neon Yellow", "Carbon Black", "Electric Blue"]
        ),
        Shoe(
            name: "Classic Comfort",
            brand: "CityWalk",
            price: 69.99,
            description: "Timeless design with all-day comfort. Perfect for work or leisure.",
            imageName: "shoe5",
            sizes: [6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0],
            colors: ["White", "Black", "Tan"]
        ),
        Shoe(
            name: "Mountain Peak",
            brand: "MountainGear",
            price: 199.99,
            description: "Waterproof hiking boots with ankle support and advanced traction system.",
            imageName: "shoe6",
            sizes: [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0, 13.0],
            colors: ["Brown", "Black", "Dark Gray"]
        )
    ]
}
