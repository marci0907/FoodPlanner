//import RxSwift
//
//class MealPlannerDetailsViewModel {
//
//    typealias service = MealPlannerService
//
//    var mealPlannerModel: MealPlannerModel?
//    var reloadSubject = PublishSubject<Bool>()
//
//    let bag = DisposeBag()
//
//    init() {
//        service().generateMealPlan()
//            .subscribe(onSuccess: { mealPlannerModel in
//                self.mealPlannerModel = mealPlannerModel
//                self.reloadSubject.onNext(true)
//            })
//            .disposed(by: bag)
//    }
//}
