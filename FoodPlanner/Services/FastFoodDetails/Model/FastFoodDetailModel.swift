import Foundation

struct FastFoodDetailModel: Codable {
    var id: Int
    var title: String
    var nutrition: FastFoodDetailNutrition
    var restaurantChain: String
}

struct FastFoodDetailNutrition: Codable {
    var caloricBreakdown: CaloricBreakdown
    var calories: Int
    var fat: String
    var protein: String
    var carbs: String
}
