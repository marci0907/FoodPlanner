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
        navigationController?.pushViewController(selectedViewController, animated: true)
    }

}
