import UIKit

class FastFoodSettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dismissingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(willDismiss))
        dismissingView.addGestureRecognizer(tapGesture)
        
        closeButton.addTarget(self, action: #selector(willDismiss), for: .touchUpInside)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(willDismiss))
        swipeGesture.direction = .down
        contentView.addGestureRecognizer(swipeGesture)
    }

    @objc func willDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
