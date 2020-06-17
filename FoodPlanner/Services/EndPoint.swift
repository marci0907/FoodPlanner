import Foundation

enum EndPoint {
    case mealPlan
    case mealImage(for: Meal)
    case mealDetail(for: Meal)
    case fastFood(withQuery: String)
    
    private var url: String {
        let base = "https://api.spoonacular.com"
        let apikey = "?apiKey=\(apiKey)"
        
        switch self {
        case .mealPlan:
            return base + "/mealplanner/generate" + apikey + "&timeFrame=day"
        case .mealImage(let meal):
            return "https://spoonacular.com/recipeImages/\(meal.id)-636x393.\(meal.imageType)"
        case .mealDetail(let meal):
            return base + "/recipes/\(meal.id)/information" + apikey + "&includeNutrition=true"
        case .fastFood(let query):
            return base + "/food/menuItems/search" + apikey + "&query=\(query)&number=20"
        }
    }
    
    var request: URLRequest {
        switch self {
        case .mealPlan:
            return URLRequest(url: URL(string: EndPoint.mealPlan.url)!)
        case .mealImage(let meal):
            return URLRequest(url: URL(string: EndPoint.mealImage(for: meal).url)!)
        case .mealDetail(let meal):
            return URLRequest(url: URL(string: EndPoint.mealDetail(for: meal).url)!)
        case .fastFood(let query):
            return URLRequest(url: URL(string: EndPoint.fastFood(withQuery: query).url)!)
        }
    }
}
