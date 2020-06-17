import RxSwift
import UIKit

class FastFoodViewController: UIViewController {

    let bag = DisposeBag()
    let viewModel = FastFoodViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getFastFood(withQuery: "burger").asObservable()
            .subscribe(onNext: { fastFoods in
                self.viewModel.fastFoods = fastFoods
            })
            .disposed(by: bag)
    }

}
