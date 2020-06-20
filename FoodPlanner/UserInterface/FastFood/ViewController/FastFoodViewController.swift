import RxSwift
import UIKit

class FastFoodViewController: UIViewController {
    
    private enum Constants {
        static let tableViewCellReuseIdentifier = "RestaurantCell"
    }

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    let viewModel = FastFoodViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
                
        viewModel.getFastFood().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] fastFoods in
                self?.viewModel.fastFoods = fastFoods
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
    }
}

extension FastFoodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

extension FastFoodViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.restaurants.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.restaurants[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier) as! FastFoodTableViewCell
        cell.cellViewModel = viewModel.restaurants[indexPath.section]
        cell.collectionView.reloadData()
        return cell
    }
}
