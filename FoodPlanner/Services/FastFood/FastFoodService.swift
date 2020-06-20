import RxCocoa
import RxSwift

final class FastFoodService {
    func getFastFood(with query: String, numberOfItems itemNumber: Int) -> Single<[FastFoodModel]> {
        return URLSession.shared.rx.response(request: EndPoint.fastFood(withQuery: query, numberOfItems: itemNumber).request)
            .map { try JSONDecoder().decode(FastFoodCollection.self, from: $1) }
            .compactMap { $0.menuItems }
            .map { foods -> [Observable<(FastFoodModel, Data?)>] in
                return foods.map { food in
                    guard let image = food.image else { return Observable.just((food, nil)) }
                    return URLSession.shared.rx.data(request: URLRequest(url: URL(string: image)!))
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
