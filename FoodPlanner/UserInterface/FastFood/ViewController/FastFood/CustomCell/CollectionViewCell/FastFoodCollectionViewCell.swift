import UIKit

class FastFoodCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    private enum Constants {
        static let detailStoryboardId = "FastFoodDetailViewController"
    }
    
    @IBOutlet weak var fastFoodImage: UIImageView!
    @IBOutlet weak var fastFoodLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    var cellViewModel: FastFoodModel! {
        didSet {
            configureCell(with: cellViewModel.imageData!)
            fastFoodLabel.text = cellViewModel!.title
        }
    }
    var longPressGesture: UILongPressGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLongPressRecognizer()
    }
    
    func configureCell(with image: Data) {
        fastFoodImage?.image = UIImage(data: image)
        fastFoodImage.layer.cornerRadius = 10.0
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 5
    }
    
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: view)
        if let pressedView = self.view.hitTest(point, with: nil), pressedView == view {
            switch recognizer.state {
            case .began:
                let storyboard = UIStoryboard(name: Constants.detailStoryboardId, bundle: .main)
                let detailVC = storyboard.instantiateInitialViewController() as! FastFoodDetailViewController
                
                detailVC.modalPresentationStyle = .overFullScreen
                detailVC.modalTransitionStyle = .crossDissolve
                
                detailVC.addRecognizer(recognizer: recognizer)
                detailVC.completionHandlerAfterDismiss = setLongPressRecognizer
                detailVC.viewModel = FastFoodDetailViewModel(selectedFood: cellViewModel)
                
                self.window?.rootViewController?.present(detailVC, animated: true, completion: removeRecognizer)
            default:
                break
            }
        }
    }
    
    private func setLongPressRecognizer() {
        if let recognizer = longPressGesture {
            longPressGesture = recognizer
            recognizer.removeTarget(nil, action: nil)
            recognizer.addTarget(self, action: #selector(longPressed(recognizer:)))
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
        } else {
            longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(recognizer:)))
            longPressGesture.delegate = self
            longPressGesture.minimumPressDuration = 0.5
            self.view.addGestureRecognizer(longPressGesture)
        }
    }
    
    private func removeRecognizer() {
        view.removeGestureRecognizer(longPressGesture)
        longPressGesture.delegate = nil
    }
}
