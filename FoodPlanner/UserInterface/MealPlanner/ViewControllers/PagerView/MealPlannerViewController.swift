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
    
    var chosenView: UIImageView!
    var chosenViewAnimation: CGAffineTransform!

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: Constants.fsCellReuseId)
            self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
            self.pagerView.itemSize = CGSize(width: 312, height: 231)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isMovingToParent {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.chosenView.transform = CGAffineTransform.identity
                    self.pagerView.alpha = 1
                },
                completion: { _ in
                    self.chosenView.removeFromSuperview()
                    self.pagerView.cellForItem(at: self.pagerView.currentIndex)?.isHidden = false
                    self.pagerView.deselectItem(at: self.pagerView.currentIndex, animated: false)
                }
            )
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
//        cell.textLabel?.text = model.meals[index].title
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard index == pagerView.currentIndex else {
            return
        }
        let selectedStoryboard = UIStoryboard(name: Constants.detailsStoryboardId, bundle: .main)
        let selectedViewController = selectedStoryboard.instantiateInitialViewController()! as MealPlannerDetailViewController
        selectedViewController.chosenMeal = viewModel.mealPlannerModel!.meals[index]
        
        pagerView.cellForItem(at: index)?.isHidden = true

        chosenView = UIImageView(frame: pagerView.cellForItem(at: index)!.frame)
        chosenView.frame.origin.y += 40
        chosenView.frame.origin.x -= CGFloat(index) * 190
        chosenView.image = UIImage(data: viewModel.mealPlannerModel!.meals[index].image!)
        view.addSubview(chosenView)
        
        let superViewChosenViewWidthRatio = view.frame.size.width / chosenView.frame.size.width
        let chosenViewDistanceFromTop = -chosenView.frame.origin.y + 82
        chosenViewAnimation = chosenView.transform.translatedBy(x: 0, y: chosenViewDistanceFromTop).scaledBy(x: superViewChosenViewWidthRatio, y: 1.1)
        
        UIView.animate(
            withDuration: 0.5,
            animations:
            {
                self.chosenView.transform = self.chosenViewAnimation
                self.pagerView.alpha = 0
            },
            completion:
            { _ in
                self.navigationController?.pushViewController(selectedViewController, animated: false)
            }
        )
    }
}

