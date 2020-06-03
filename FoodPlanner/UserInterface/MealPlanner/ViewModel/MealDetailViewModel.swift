import RxSwift

class MealDetailViewModel {

    typealias service = MealDetailService

    var mealImage: Data!
    var mealDetailModel: MealDetailModel?
    var reloadSubject = PublishSubject<Bool>()

    let bag = DisposeBag()

    init(withMeal meal: Meal) {
        mealImage = meal.image!
        service().getMealDetails(for: meal)
            .subscribe(onSuccess: { mealDetailModel in
                self.mealDetailModel = mealDetailModel
                self.reloadSubject.onNext(true)
            })
            .disposed(by: bag)
    }
}
