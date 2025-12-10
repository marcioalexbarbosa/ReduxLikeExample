import Foundation

/// Modelo de produto
struct Product: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let price: Double
    let category: String
    let inStock: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        category: String,
        inStock: Bool = true
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
        self.inStock = inStock
    }
}

// MARK: - Mock Data

extension Product {
    static let mockProducts: [Product] = [
        Product(name: "iPhone 15 Pro", price: 7999.00, category: "Smartphones", inStock: true),
        Product(name: "MacBook Air M2", price: 9999.00, category: "Laptops", inStock: true),
        Product(name: "AirPods Pro", price: 2499.00, category: "Audio", inStock: false),
        Product(name: "iPad Pro", price: 8999.00, category: "Tablets", inStock: true),
        Product(name: "Apple Watch Ultra", price: 6999.00, category: "Wearables", inStock: true),
        Product(name: "Magic Keyboard", price: 1299.00, category: "Accessories", inStock: true),
        Product(name: "Studio Display", price: 14999.00, category: "Displays", inStock: false),
        Product(name: "Mac Mini M2", price: 5999.00, category: "Desktops", inStock: true),
    ]
}
