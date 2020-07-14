import RxSwift

class FastFoodViewModel {
    
    typealias service = FastFoodService
    
    private let bag = DisposeBag()
    var fastFoods: [FastFoodModel]? {
        didSet {
            removeCategories()
            setCategories()
        }
    }
    var restaurants = [Restaurant]()
    
    func getFastFood(withQuery query: String = "burger", numberOfItems number: Int = 40) -> Single<[FastFoodModel]> {
        return service().getFastFood(with: query, numberOfItems: number)
    }
    
    private func removeCategories() {
        restaurants = []
    }
    
    private func setCategories() {
        guard let foods = fastFoods else { return }
        let restaurantSet = Set(foods.map { $0.restaurantChain! })
        
        restaurantSet.forEach { currentRestaurant in
            let foods = foods.filter { $0.restaurantChain! == currentRestaurant && $0.imageData != nil }
            guard foods.count > 0 else { return }
            let restaurant = Restaurant(name: currentRestaurant, foods: foods)
            self.restaurants.append(restaurant)
        }
        restaurants.sort(by: { $0.foods.count > $1.foods.count })
    }
}

struct Restaurant {
    var name: String
    var foods: [FastFoodModel]
}
