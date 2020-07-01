import RxSwift
import UIKit

class FastFoodDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var fastFoodImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var bag = DisposeBag()
    var completionHandlerAfterDismiss: () -> Void = {}
    var longPressGesture: UILongPressGestureRecognizer!
    var viewModel: FastFoodDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLongPressGesture()
        
        viewModel.getDetailsForSelectedFood().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [unowned self] fastFoodModel in
                self.fastFoodImage.image = UIImage(data: self.viewModel.selectedFood.imageData!)
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(longPressGesture)
        longPressGesture.delegate = nil
    }
    
    private func setLongPressGesture() {
        longPressGesture.removeTarget(nil, action: nil)
        longPressGesture.addTarget(self, action: #selector(longPressed(recognizer:)))
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .ended, .cancelled:
            self.dismiss(animated: true, completion: completionHandlerAfterDismiss)
        default:
            break
        }
    }
    
    func addRecognizer(recognizer: UILongPressGestureRecognizer) {
        self.longPressGesture = recognizer
    }

}
