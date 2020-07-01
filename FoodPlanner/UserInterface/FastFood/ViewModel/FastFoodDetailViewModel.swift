import Foundation
import RxSwift

final class FastFoodDetailViewModel {
    
    private typealias service = FastFoodDetailService
    
    var selectedFood: FastFoodModel
    
    init(selectedFood: FastFoodModel) {
        self.selectedFood = selectedFood
    }
    
    func getDetailsForSelectedFood() -> Single<FastFoodDetailModel> {
        return service().getDetails(for: selectedFood)
    }
}
