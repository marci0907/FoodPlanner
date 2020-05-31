import RxCocoa
import RxSwift

struct MealPlannerService {
    func generateMealPlan() -> Single<MealPlannerModel> {
        let urlRequest = URLRequest(url: URL(string: EndPoint.mealPlan.url)!)
        return URLSession.shared.rx.response(request: urlRequest)
            .map { try JSONDecoder().decode(MealPlannerModel.self, from: $1) }
            .asSingle()
    }
}
