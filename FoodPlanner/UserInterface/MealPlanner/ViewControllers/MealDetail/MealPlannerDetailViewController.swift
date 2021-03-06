import NVActivityIndicatorView
import RxSwift
import UIKit

class MealPlannerDetailViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var directionsTableView: UITableView! {
        didSet {
            self.directionsTableView.register(UINib(nibName: "DirectionCell", bundle: .main), forCellReuseIdentifier: "DirectionCell")
            self.directionsTableView.rx.setDelegate(self)
                .disposed(by: bag)
            self.directionsTableView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView! {
        didSet {
            self.ingredientsTableView.rx.setDelegate(self)
                .disposed(by: bag)
            self.ingredientsTableView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet var nutrients: [UILabel]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var directionsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    
    var activityIndicator: NVActivityIndicatorView!
    var bag = DisposeBag()
    var viewModel: MealDetailViewModel!
    
    let minImageTrailingDistance: CGFloat = 0
    let maxImageTrailingDistance: CGFloat = 314
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mealImage.image = UIImage(data: viewModel.meal.image!)
        
        scrollView.delegate = self
        
        frameView.layer.cornerRadius = 12
        frameView.layer.borderWidth = 1
        frameView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.arrangedSubviews.forEach {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        setupSwipeGestureRecogniser()
        setupActivityIndicator()
        
        scrollView.rx.didScroll
            .observeOn(MainScheduler())
            .subscribe(onNext: { _ in
                self.directionsTableViewHeightConstraint?.constant = self.directionsTableView.contentSize.height
            })
            .disposed(by: bag)
                
        viewModel.ingredientsSubject
            .bind(to: ingredientsTableView.rx.items(cellIdentifier: "IngredientCell", cellType: IngredientsCell.self)) { _, item, cell in
                self.view.layoutIfNeeded()
                self.view.setNeedsLayout()
                self.ingredientTableViewHeightConstraint?.constant = self.ingredientsTableView.contentSize.height
                cell.ingredientLabel.text = item.original
            }
            .disposed(by: bag)
        
        viewModel.directionsSubject
            .bind(to: directionsTableView.rx.items(cellIdentifier: "DirectionCell", cellType: DirectionCell.self)) { row, item, cell in
                guard
                    let number = item.number,
                    let step = item.step
                else {
                    cell.countLabel?.text = ""
                    cell.stepLabel.text = ""
                    return
                }
                cell.countLabel?.text = "\(number)."
                cell.stepLabel?.text = "\(step)"
            }
            .disposed(by: bag)
        
        viewModel.getDetails().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] mealDetailModel in
                self?.viewModel.mealDetailModel = mealDetailModel
                self?.viewModel.ingredientsSubject.onNext(mealDetailModel.extendedIngredients)
                if let instructions = mealDetailModel.analyzedInstructions.first {
                    self?.viewModel.directionsSubject.onNext(instructions.steps)
                }
                self?.updateUI(with: mealDetailModel)
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
    }
    
    func updateUI(with meal: MealDetailModel) {
        headerTitleLabel.text = meal.title
        headerTitleLabel.alpha = 0
        scrollView.isHidden = false
        titleLabel.text = meal.title
        
        let calories = viewModel.mealDetailModel!.nutrition!.nutrients.filter({ $0.title == "Calories" }).first!
        nutrients[0].text = "\(Int(calories.amount))"
        
        let carbs = viewModel.mealDetailModel!.nutrition!.nutrients.filter({ $0.title == "Carbohydrates" }).first!
        nutrients[1].text = "\(Int(carbs.amount)) " + carbs.unit
        
        let protein = viewModel.mealDetailModel!.nutrition!.nutrients.filter({ $0.title == "Protein" }).first!
        nutrients[2].text = "\(Int(protein.amount)) " + protein.unit

        let fat = viewModel.mealDetailModel!.nutrition!.nutrients.filter({ $0.title == "Fat" }).first!
        nutrients[3].text = "\(Int(fat.amount)) " + fat.unit
    }
    
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50),
                                                    type: .circleStrokeSpin,
                                                    color: .black,
                                                    padding: 2.0)
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
        scrollView.isHidden = true
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

extension MealPlannerDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let newTrailingDistance = trailingImageConstraint.constant + y
        
        if newTrailingDistance > maxImageTrailingDistance {
            bottomImageConstraint.constant = 5
            leadingImageConstraint.constant = 6
            trailingImageConstraint.constant = maxImageTrailingDistance
        } else if newTrailingDistance < minImageTrailingDistance {
            bottomImageConstraint.constant = 0
            leadingImageConstraint.constant = 0
            trailingImageConstraint.constant = minImageTrailingDistance
        } else {
            bottomImageConstraint.constant = newTrailingDistance / 60
            leadingImageConstraint.constant = newTrailingDistance / 50
            trailingImageConstraint.constant = newTrailingDistance
            scrollView.contentOffset.y = 0
        }
        
        if y > 40.0 && headerTitleLabel.alpha < 1 {
            headerTitleLabel.alpha += y / 100
        } else if headerTitleLabel.alpha > 0 {
            headerTitleLabel.alpha -= 0.2
        } else if y < 10 {
            headerTitleLabel.alpha = 0
        }
    }
}
