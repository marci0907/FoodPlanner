import NVActivityIndicatorView
import RxSwift
import UIKit

class FastFoodViewController: UIViewController {
    
    private enum Constants {
        static let tableViewHeaderHeight: CGFloat = 80.0
        static let tableViewCellReuseIdentifier = "RestaurantCell"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.clear
        }
    }
    
    private var collectionViewOffsets = [IndexPath: CGFloat]()
    
    private var activityIndicator: NVActivityIndicatorView!
    private let bag = DisposeBag()
    private let viewModel = FastFoodViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: Constants.tableViewHeaderHeight))
        tableView.contentInset = UIEdgeInsets(top: -Constants.tableViewHeaderHeight, left: 0, bottom: 0, right: 0)
        
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.placeholder = "Search for fast foods"
        
        setupActivityIndicator()
        setupTapGestureRecogniser()
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(900), scheduler: MainScheduler())
            .map { text -> String in
                let text = text.isEmpty ? "burger" : text
                return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
            .flatMap { text -> Observable<[FastFoodModel]> in
                self.activityIndicator.startAnimating()
                return self.viewModel.getFastFood(withQuery: text, numberOfItems: 40).asObservable()
                    .catchErrorJustReturn([])
            }
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] fastFoods in
                self?.viewModel.fastFoods = fastFoods
                self?.tableView.reloadData()
                self?.collectionViewOffsets = [:]
                self?.activityIndicator.stopAnimating()
            })
            .disposed(by: bag)
        
        tableView.rx.didScroll
            .subscribe(onNext: { _ in
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: bag)
    }
    
    private func setupTapGestureRecogniser() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarResignFirstResponder))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func searchBarResignFirstResponder() {
        searchBar.resignFirstResponder()
    }
    
    private func setupActivityIndicator() {
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
        
        let maximumImageSize = CGFloat(164)
        let currentImageSize = image!.size.height

        return currentImageSize > maximumImageSize ? maximumImageSize + 50 : currentImageSize + 50
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
        return Constants.tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FastFoodTableViewCell else { return }
        cell.collectionViewCellOffset = collectionViewOffsets[indexPath] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FastFoodTableViewCell else { return }
        collectionViewOffsets[indexPath] = cell.collectionViewCellOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = tableView.contentOffset.y
        let searchBarHeight: CGFloat = 44.0
        if offset < Constants.tableViewHeaderHeight && searchBarHeightConstraint.constant < searchBarHeight {
            searchBarHeightConstraint.constant += 80 - offset
            searchBarHeightConstraint.constant = searchBarHeightConstraint.constant > searchBarHeight ? searchBarHeight : searchBarHeightConstraint.constant
            tableView.contentOffset.y = Constants.tableViewHeaderHeight
            searchBar.isUserInteractionEnabled = false
        } else if offset > Constants.tableViewHeaderHeight && searchBarHeightConstraint.constant > 0 {
            searchBarHeightConstraint.constant -= offset - 80
            tableView.contentOffset.y = Constants.tableViewHeaderHeight
            searchBar.isUserInteractionEnabled = false
        } else {
            searchBar.isUserInteractionEnabled = true
        }
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
