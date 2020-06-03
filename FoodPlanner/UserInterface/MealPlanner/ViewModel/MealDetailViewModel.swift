import RxSwift

class MealDetailViewModel {

    typealias service = MealDetailService

    var meal: Meal!
    var mealDetailModel: MealDetailModel?
    var reloadSubject = PublishSubject<Bool>()

    let bag = DisposeBag()

    init(withMeal meal: Meal) {
        self.meal = meal
    }
    
    func getDetails() {
        service().getMealDetails(for: meal)
            .subscribe(onSuccess: { mealDetailModel in
                self.mealDetailModel = mealDetailModel
                self.reloadSubject.onNext(true)
            })
            .disposed(by: bag)
    }
}
