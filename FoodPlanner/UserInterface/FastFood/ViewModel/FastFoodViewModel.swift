import RxSwift

class FastFoodViewModel {
    
    typealias service = FastFoodService
    
    let bag = DisposeBag()
    var fastFoods: [FastFoodModel]? {
        didSet {
            setCategories()
        }
    }
    var restaurants = [Restaurant]()
    
    func getFastFood(withQuery query: String = "burger", numberOfItems number: Int = 40) -> Single<[FastFoodModel]> {
        return service().getFastFood(with: query, numberOfItems: number)
    }
    
    private func setCategories() {
        guard let foods = fastFoods else { return }
        let restaurantArray = Set(foods.map { $0.restaurantChain! })
        
        restaurantArray.forEach { currentRestaurant in
            var restaurant: Restaurant = Restaurant(name: "", foods: [])
            restaurant.name = currentRestaurant
            restaurant.foods = foods.filter { $0.restaurantChain! == currentRestaurant && $0.imageData != nil }
            self.restaurants.append(restaurant)
        }
        restaurants.sort(by: { $0.foods.count > $1.foods.count })
    }
}

struct Restaurant {
    var name: String
    var foods: [FastFoodModel]
}
