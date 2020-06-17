import RxSwift

class FastFoodViewModel {
    
    typealias service = FastFoodService
    
    let bag = DisposeBag()
    var fastFoods: [FastFoodModel]?
    
    func getFastFood(withQuery query: String) -> Single<[FastFoodModel]> {
        return service().getFastFood(with: query)
    }
}
