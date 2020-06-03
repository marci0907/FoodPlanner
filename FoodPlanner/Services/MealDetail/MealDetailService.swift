import RxCocoa
import RxSwift

final class MealDetailService {
    func getMealDetails(for meal: Meal) -> Single<MealDetailModel> {
        return URLSession.shared.rx.response(request: EndPoint.mealDetail(for: meal).request)
            .map { try JSONDecoder().decode(MealDetailModel.self, from: $1) }
            .asSingle()
    }
}
