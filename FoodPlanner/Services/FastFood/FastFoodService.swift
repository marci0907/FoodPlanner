import RxCocoa
import RxSwift

final class FastFoodService {
    func getFastFood(with query: String) -> Single<[FastFoodModel]> {
        return URLSession.shared.rx.response(request: EndPoint.fastFood(withQuery: query).request)
            .map { try JSONDecoder().decode(FastFoodCollection.self, from: $1) }
            .compactMap { $0.menuItems }
            .map { foods -> [Observable<(FastFoodModel, Data)>] in
                return foods.map { food in
                    return URLSession.shared.rx.data(request: URLRequest(url: URL(string: food.image!)!))
                        .map { (food, $0)}
                }
            }
            .flatMap { fastFoods in
                Observable.zip(fastFoods)
            }
            .map { arrayOfFoodsAndImages in
                return arrayOfFoodsAndImages.map { food, image in
                    var food = food
                    food.imageData = image
                    return food
                }
            }
            .asSingle()
    }
}
