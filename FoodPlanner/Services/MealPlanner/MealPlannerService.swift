import Foundation
import RxCocoa
import RxSwift

struct MealPlannerService {
    func generateMealPlan() -> Single<MealPlannerModel> {
        let urlRequest = URLRequest(url: URL(string: EndPoint.mealPlan.url)!)
        return URLSession.shared.rx.response(request: urlRequest)
            .map { try JSONDecoder().decode(MealPlannerModel.self, from: $1) }
            .map { mealPlannerModel -> [Observable<(Meal, Nutrients, Data)>] in
                return mealPlannerModel.meals.map { meal -> Observable<(Meal, Nutrients, Data)> in
                    return URLSession.shared.rx.data(request: URLRequest(url: URL(string: EndPoint.mealPlan.url(for: meal))!))
                        .map { (meal, mealPlannerModel.nutrients, $0) }
                }
            }
            .flatMap { meals in
                Observable.zip(meals)
            }
            .map { array in
                let meals = array.map { (meal, _, imageData) -> Meal in
                    var meal = meal
                    meal.image = imageData
                    return meal
                }
                return MealPlannerModel(meals: meals, nutrients: array.first!.1)
            }
            .asSingle()
    }
}
