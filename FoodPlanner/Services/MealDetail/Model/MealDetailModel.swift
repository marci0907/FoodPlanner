struct MealDetailModel: Codable {
    let glutenFree, dairyFree: Bool
    let preparationMinutes: Int?
    let cookingMinutes: Int?
    let healthScore: Int
    let extendedIngredients: [ExtendedIngredient]
    let id: Int
    let title: String
    let readyInMinutes, servings: Int
    let nutrition: Nutrition
    let analyzedInstructions: [AnalyzedInstruction]
}

struct AnalyzedInstruction: Codable {
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let step: String
}

struct ExtendedIngredient: Codable {
    let id: Int
    let name: String
    let original: String
}

struct Nutrition: Codable {
    let nutrients: [Nutrient]
    let caloricBreakdown: CaloricBreakdown
}

struct CaloricBreakdown: Codable {
    let percentProtein, percentFat, percentCarbs: Double
}

struct Nutrient: Codable {
    let title: String
    let amount: Double
    let unit: String
}
