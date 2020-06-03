import Foundation

enum EndPoint {
    case mealPlan
    case mealImage(for: Meal)
    case mealDetail(for: Meal)
    
    var url: String {
        let base = "https://api.spoonacular.com"
        let apikey = "?apiKey=\(apiKey)"
        
        switch self {
        case .mealPlan:
            return base + "/mealplanner/generate" + apikey + "&timeFrame=day"
        case .mealImage(let meal):
            return "https://spoonacular.com/recipeImages/\(meal.id)-636x393.\(meal.imageType)"
        case .mealDetail(let meal):
            return base + "recipes/\(meal.id)/information?includeNutrition=true"
        }
    }
    
    var request: URLRequest {
        let base = "https://api.spoonacular.com"
        let apikey = "?apiKey=\(apiKey)"
        
        switch self {
        case .mealPlan:
            return URLRequest(url: URL(string: base + "/mealplanner/generate" + apikey + "&timeFrame=day")!)
        case .mealImage(let meal):
            return URLRequest(url: URL(string: "https://spoonacular.com/recipeImages/\(meal.id)-636x393.\(meal.imageType)")!)
        case .mealDetail(let meal):
            return URLRequest(url: URL(string: base + "/recipes/\(meal.id)/information" + apikey + "&includeNutrition=true")!)
        }

    }
}
