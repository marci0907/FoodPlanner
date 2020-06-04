import RxSwift
import UIKit

class MealPlannerDetailViewController: UIViewController {
    
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: MealDetailViewModel!
    var activityIndicator: UIActivityIndicatorView!
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealImage.image = UIImage(data: viewModel.meal.image!)
        
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
        titleLabel.text = meal.title
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        contentView.addSubview(activityIndicator)
        
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
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
