struct MealPlannerModel: Codable {
    var meals: [Meal]
    var nutrients: Nutrients
}

struct Meal: Codable {
    var id: Int
    var title: String
    var imageType: String
    var readyInMinutes: Int
    var servings: Int
    var sourceUrl: String
}

struct Nutrients: Codable {
    var calories: Double
    var carbohydrates: Double
    var fat: Double
    var protein: Double
}
