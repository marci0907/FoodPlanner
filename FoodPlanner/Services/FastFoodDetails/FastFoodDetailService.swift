import RxCocoa
import RxSwift

final class FastFoodDetailService {
    func getDetails(for fastFood: FastFoodModel) -> Single<FastFoodDetailModel> {
        return URLSession.shared.rx.response(request: EndPoint.fastFoodDetail(for: fastFood).request)
            .map { $1 }
            .map { try JSONDecoder().decode(FastFoodDetailModel.self, from: $0) }
            .asSingle()
    }
}
