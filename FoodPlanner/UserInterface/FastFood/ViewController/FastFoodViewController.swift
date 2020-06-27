import NVActivityIndicatorView
import RxSwift
import UIKit

class FastFoodViewController: UIViewController {
    
    private enum Constants {
        static let tableViewCellReuseIdentifier = "RestaurantCell"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.clear
        }
    }
    var activityIndicator: NVActivityIndicatorView!
    let bag = DisposeBag()
    let viewModel = FastFoodViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 80))
        tableView.contentInset = UIEdgeInsets(top: -80, left: 0, bottom: 0, right: 0)
        
        searchBar.delegate = self
        
        setupActivityIndicator()
        
        viewModel.getFastFood().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] fastFoods in
                self?.viewModel.fastFoods = fastFoods
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
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
}

extension FastFoodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageData = viewModel.restaurants[indexPath.section].foods[indexPath.row].imageData!
        let image = UIImage(data: imageData)
        
        let maximumImageSize = CGFloat(156)
        let currentImageSize = image!.size.height

        return currentImageSize > maximumImageSize ? maximumImageSize + 34 : currentImageSize + 34
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.contentView.backgroundColor = UIColor.white
        headerView.backgroundColor = UIColor.white
        headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 40)
        headerView.textLabel?.text = viewModel.restaurants[section].name
        headerView.textLabel?.textColor = UIColor.black
        headerView.textLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}

extension FastFoodViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.restaurants.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier) as! FastFoodTableViewCell
        cell.cellViewModel = viewModel.restaurants[indexPath.section]
        cell.collectionView.reloadData()
        return cell
    }
}

extension FastFoodViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard var text = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        activityIndicator.startAnimating()
        
        if text == "" {
            text = "burger"
        }
        
        viewModel.getFastFood(withQuery: text).asObservable()
            .observeOn(MainScheduler())
            .debounce(.milliseconds(1000), scheduler: MainScheduler())
            .subscribe(onNext: { [weak self] fastFoods in
                self?.viewModel.fastFoods = fastFoods
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
    }
}
