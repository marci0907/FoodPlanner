import UIKit

class FastFoodDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    var completionHandlerAfterDismiss: () -> Void = {}
    var longPressGesture: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        longPressGesture.removeTarget(nil, action: nil)
        longPressGesture.addTarget(self, action: #selector(longPressed(recognizer:)))
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(longPressGesture)
        longPressGesture.delegate = nil
    }
    
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            self.dismiss(animated: true, completion: completionHandlerAfterDismiss)
        default:
            break
        }
    }
    
    func addRecognizer(recognizer: UILongPressGestureRecognizer) {
        self.longPressGesture = recognizer
    }

}
