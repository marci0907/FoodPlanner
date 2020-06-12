import FSPagerView
import NVActivityIndicatorView
import RxSwift
import UIKit

class MealPlannerViewController: UIViewController {
    
    private enum Constants {
        static let detailsStoryboardId = "MealPlannerDetailViewController"
        static let fsCellReuseId = "FSCell"
    }
    
    var activityIndicator: NVActivityIndicatorView!
    var bag = DisposeBag()
    var chosenView: UIImageView!
    var chosenViewAnimation: CGAffineTransform!
    var currentPagerIndex = 0
    var viewModel: MealPlannerViewModel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nutrientsStackView: UIStackView!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: Constants.fsCellReuseId)
            self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
            self.pagerView.itemSize = CGSize(width: 312, height: 231)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MealPlannerViewModel()
        
        setupActivityIndicator()
        
        viewModel.getMealPlan().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { mealPlannerModel in
                self.viewModel.mealPlannerModel = mealPlannerModel
                self.pagerView.reloadData()
                self.nutrientsStackView.isHidden = false
                self.setLabels()
                self.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isMovingToParent {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.chosenView?.transform = CGAffineTransform.identity
                    self.pagerView.alpha = 1
                    self.nutrientsStackView.alpha = 1
                },
                completion: { _ in
                    self.chosenView?.removeFromSuperview()
                    self.pagerView.cellForItem(at: self.pagerView.currentIndex)?.isHidden = false
                    self.pagerView.deselectItem(at: self.pagerView.currentIndex, animated: false)
                }
            )
        }
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
    }
    
    func setLabels() {
        let index = pagerView.currentIndex
        titleLabel.text = viewModel.mealPlannerModel!.meals[index].title
        
        calorieLabel.text = "\(viewModel.mealPlannerModel!.nutrients.calories) kcal"
        carbohydrateLabel.text = "\(viewModel.mealPlannerModel!.nutrients.carbohydrates) g"
        proteinLabel.text = "\(viewModel.mealPlannerModel!.nutrients.protein) g"
        fatLabel.text = "\(viewModel.mealPlannerModel!.nutrients.fat) g"
    }
    
    fileprivate func setChosenView(fromItemAt index: Int) {
        chosenView = UIImageView(frame: pagerView.cellForItem(at: index)!.frame)
        chosenView.frame.origin.y += 40
        chosenView.frame.origin.x -= CGFloat(index) * 190
        chosenView.image = UIImage(data: viewModel.mealPlannerModel!.meals[index].image!)
        view.addSubview(chosenView)
        
        let superViewChosenViewWidthRatio = view.frame.size.width / chosenView.frame.size.width
        let chosenViewDistanceFromTop = -chosenView.frame.origin.y + 57
        chosenViewAnimation = chosenView.transform.translatedBy(x: 0, y: chosenViewDistanceFromTop).scaledBy(x: superViewChosenViewWidthRatio, y: 1.11)
    }

}

// MARK: - FSPagerView DataSource

extension MealPlannerViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.mealPlannerModel?.meals.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: Constants.fsCellReuseId, at: index)
        guard let model = viewModel.mealPlannerModel else { return cell }
        
        cell.imageView?.image = UIImage(data: model.meals[index].image!)
        return cell
    }
}

// MARK: - FSPagerView Delegate

extension MealPlannerViewController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard index == pagerView.currentIndex else {
            return
        }
        let selectedMeal = viewModel.mealPlannerModel!.meals[index]
        
        let selectedStoryboard = UIStoryboard(name: Constants.detailsStoryboardId, bundle: .main)
        let selectedViewController = selectedStoryboard.instantiateInitialViewController()! as MealPlannerDetailViewController
        selectedViewController.viewModel = MealDetailViewModel(withMeal: selectedMeal)
        
        pagerView.cellForItem(at: index)?.isHidden = true

        setChosenView(fromItemAt: index)
        
        UIView.animate(
            withDuration: 0.3,
            animations:
            {
                self.chosenView.transform = self.chosenViewAnimation
                self.pagerView.alpha = 0
                self.nutrientsStackView.alpha = 0
            },
            completion:
            { _ in
                self.navigationController?.pushViewController(selectedViewController, animated: false)
            }
        )
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if (currentPagerIndex - pagerView.currentIndex) > 1 {
            return
        }
        currentPagerIndex = pagerView.currentIndex
        setLabels()
    }
}

