enum EndPoint {
    case mealPlan
    
    var url: String {
        let base = "https://api.spoonacular.com"
        let apikey = "?apiKey=\(apiKey)"
        
        switch self {
        case .mealPlan:
            return base + "/mealplanner/generate" + apikey + "&timeFrame=day"
        }
    }
}
