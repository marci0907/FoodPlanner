import RxSwift

class MealDetailViewModel {

    typealias service = MealDetailService
    
    var ingredientsSubject = PublishSubject<[ExtendedIngredient]>()
    var meal: Meal!
    var mealDetailModel: MealDetailModel?

    let bag = DisposeBag()

    init(withMeal meal: Meal) {
        self.meal = meal
    }
    
    func getDetails() -> Single<MealDetailModel> {
        return service().getMealDetails(for: meal)
    }
}
