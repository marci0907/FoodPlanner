import UIKit

class MealPlannerDetailViewController: UIViewController {
    
    @IBOutlet weak var mealImage: UIImageView!
    
    var chosenMeal: Meal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealImage.image = UIImage(data: chosenMeal.image!)
        
        setupSwipeGestureRecogniser()
    }
    
    func setupSwipeGestureRecogniser() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
}
