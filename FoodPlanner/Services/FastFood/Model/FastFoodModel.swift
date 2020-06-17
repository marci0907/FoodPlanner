import Foundation

struct FastFoodModel: Codable {
    let id: Int?
    let title: String?
    let restaurantChain: String?
    let image: String?
    var imageData: Data?
}

struct FastFoodCollection: Codable {
    let menuItems: [FastFoodModel]?
}
