import RxSwift

class MealPlannerViewModel {
    
    typealias service = MealPlannerService
    
    var mealPlannerModel: MealPlannerModel?
    
    let bag = DisposeBag()
    
    func getMealPlan() -> Single<MealPlannerModel> {
        return service().generateMealPlan()
    }
}
