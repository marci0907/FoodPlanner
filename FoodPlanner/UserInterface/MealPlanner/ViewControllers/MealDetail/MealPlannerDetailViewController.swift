import UIKit

class MealPlannerDetailViewController: UIViewController {
    
    @IBOutlet weak var mealImage: UIImageView!
    
    var viewModel: MealDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealImage.image = UIImage(data: viewModel.mealImage)
        
        setupSwipeGestureRecogniser()
    }
    
    func setupSwipeGestureRecogniser() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: false)
    }
}
