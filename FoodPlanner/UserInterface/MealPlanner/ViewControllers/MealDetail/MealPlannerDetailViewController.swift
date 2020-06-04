import RxSwift
import UIKit

class MealPlannerDetailViewController: UIViewController {
    
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollContent: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var nutrients: [UILabel]!
    
    var viewModel: MealDetailViewModel!
    var activityIndicator: UIActivityIndicatorView!
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealImage.image = UIImage(data: viewModel.meal.image!)
        
        frameView.layer.cornerRadius = 12
        frameView.layer.borderWidth = 1
        frameView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.arrangedSubviews.forEach {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        setupSwipeGestureRecogniser()
        setupActivityIndicator()
                
        viewModel.getDetails().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { mealDetailModel in
                self.viewModel.mealDetailModel = mealDetailModel
                self.updateUI(with: mealDetailModel)
                self.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
    }
    
    func updateUI(with meal: MealDetailModel) {
        scrollContent.isHidden = false
        titleLabel.text = meal.title
        
        let calories = viewModel.mealDetailModel!.nutrition.nutrients.filter({ $0.title == "Calories" }).first!
        nutrients[0].text = "\(Int(calories.amount))"
        
        let carbs = viewModel.mealDetailModel!.nutrition.nutrients.filter({ $0.title == "Carbohydrates" }).first!
        nutrients[1].text = "\(Int(carbs.amount)) " + carbs.unit
        
        let protein = viewModel.mealDetailModel!.nutrition.nutrients.filter({ $0.title == "Protein" }).first!
        nutrients[2].text = "\(Int(protein.amount)) " + protein.unit

        let fat = viewModel.mealDetailModel!.nutrition.nutrients.filter({ $0.title == "Fat" }).first!
        nutrients[3].text = "\(Int(fat.amount)) " + fat.unit
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        view.addSubview(activityIndicator)
        
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
        scrollContent.isHidden = true
    }
    
    func setupSwipeGestureRecogniser() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swipeGesture.direction = .down
        mealImage.isUserInteractionEnabled = true
        mealImage.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: false)
    }
}
