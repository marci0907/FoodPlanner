import FSPagerView
import RxSwift
import UIKit

class MealPlannerViewController: UIViewController {
    
    private enum Constants {
        static let fsCellReuseId = "FSCell"
        static let detailsStoryboardId = "MealPlannerDetailViewController"
    }
    
    var viewModel: MealPlannerViewModel!
    var bag = DisposeBag()
    
    let zoomNav = ZoomNavigation()

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
        
        navigationController?.delegate = self
        
        viewModel.reloadSubject
            .observeOn(MainScheduler())
            .subscribe(onNext: { _ in
                self.pagerView.reloadData()
            })
            .disposed(by: bag)
    }
}

// MARK: - FSPagerView DataSource + Delegate

extension MealPlannerViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.mealPlannerModel?.meals.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: Constants.fsCellReuseId, at: index)
        guard let model = viewModel.mealPlannerModel else { return cell }
        
        cell.imageView?.image = UIImage(data: model.meals[index].image!)
        cell.textLabel?.text = model.meals[index].title
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let selectedStoryboard = UIStoryboard(name: Constants.detailsStoryboardId, bundle: .main)
        let selectedViewController = selectedStoryboard.instantiateInitialViewController()! as MealPlannerDetailViewController
        selectedViewController.chosenMeal = viewModel.mealPlannerModel!.meals[index]
        
        let chosenView = pagerView.cellForItem(at: index)!

        let superViewChosenViewWidthRatio = view.frame.size.width / chosenView.frame.size.width
        let chosenViewDistanceFromTop = -chosenView.frame.origin.y + 40
        let transform = chosenView.transform.translatedBy(x: 0, y: chosenViewDistanceFromTop).scaledBy(x: superViewChosenViewWidthRatio, y: 1.1)
        
        UIView.animate(
            withDuration: 0.5,
            animations:
            {
                chosenView.transform = transform
            },
            completion:
            { _ in
                self.navigationController?.pushViewController(selectedViewController, animated: false)
                chosenView.transform = CGAffineTransform.identity
            })
        
    }

}

// MARK: - Custom Navigation Animation

extension MealPlannerViewController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        zoomNav.isPop = operation == .pop
        return zoomNav
    }
}
