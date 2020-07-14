import Charts
import RxSwift
import UIKit

class FastFoodDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fastFoodImage: UIImageView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var bag = DisposeBag()
    var completionHandlerAfterDismiss: () -> Void = {}
    var longPressGesture: UILongPressGestureRecognizer!
    var viewModel: FastFoodDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLongPressGesture()
        updateUI()
        
        viewModel.getDetailsForSelectedFood().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [unowned self] fastFoodModel in
                self.fastFoodImage.image = UIImage(data: self.viewModel.selectedFood.imageData!)
                self.titleLabel.text = fastFoodModel.title
                self.viewModel.setup(self.pieChart, with: fastFoodModel)
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(longPressGesture)
        longPressGesture.delegate = nil
    }
    
    private func updateUI() {
        containerView.layer.cornerRadius = 10.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 5
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.insertSubview(blurEffectView, belowSubview: containerView)
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
