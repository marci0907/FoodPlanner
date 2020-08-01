import UIKit

class FastFoodSettingsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dismissingView: UIView!

    @IBOutlet var kcalSlider: CustomSlider!
    @IBOutlet var carbSlider: CustomSlider!
    @IBOutlet var proteinSlider: CustomSlider!
    @IBOutlet var fatSlider: CustomSlider!
    @IBOutlet var numberSlider: CustomSlider!

    var modalDidDismiss: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(willDismiss))
        dismissingView.addGestureRecognizer(tapGesture)
        
        closeButton.addTarget(self, action: #selector(willDismiss), for: .touchUpInside)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(willDismiss))
        swipeGesture.direction = .down
        contentView.addGestureRecognizer(swipeGesture)

        kcalSlider = CustomSlider(forType: .kcal)
        carbSlider = CustomSlider(forType: .carb)
        proteinSlider = CustomSlider(forType: .protein)
        fatSlider = CustomSlider(forType: .fat)
        numberSlider = CustomSlider(forType: .numberOfItems)
    }
    
    @objc func willDismiss() {
        modalDidDismiss()
        self.dismiss(animated: true, completion: nil)
    }
}
