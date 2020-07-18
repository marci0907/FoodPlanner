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
        
        setupBarButtonItem()
        setupActivityIndicator()
        setupTapGestureRecogniser()
        setupSearchBar()
        setupTableView()
    }
    
    private func setupTapGestureRecogniser() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchBarResignFirstResponder))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func searchBarResignFirstResponder() {
        searchBar.resignFirstResponder()
    }
    
    private func setupBarButtonItem() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "gearIcon"), for: .normal)
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        let settingsItem = UIBarButtonItem(customView: button)

        navigationItem.rightBarButtonItem = settingsItem
    }
    
    @objc func settingsTapped() {
        let storyboard = UIStoryboard(name: "FastFoodSettingsViewController", bundle: .main)
        let settingsVC = storyboard.instantiateInitialViewController()!
        settingsVC.modalTransitionStyle = .coverVertical
        settingsVC.modalPresentationStyle = .overFullScreen
        settingsVC.isModalInPresentation = true
        navigationController?.present(settingsVC, animated: true, completion: nil)
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
    
    private func setupSearchBar() {
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.placeholder = "Search for fast foods"

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
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: Constants.tableViewHeaderHeight))
        tableView.contentInset = UIEdgeInsets(top: -Constants.tableViewHeaderHeight, left: 0, bottom: 0, right: 0)

        tableView.rx.didScroll
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
                self?.updateSearchBarHeight()
            })
            .disposed(by: bag)
        
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] event in
                guard let cell = event.cell as? FastFoodTableViewCell else { return }
                cell.collectionViewCellOffset = self?.collectionViewOffsets[event.indexPath] ?? 0
            })
            .disposed(by: bag)
        
        tableView.rx.didEndDisplayingCell
            .subscribe(onNext: { [weak self] event in
                guard let cell = event.cell as? FastFoodTableViewCell else { return }
                self?.collectionViewOffsets[event.indexPath] = cell.collectionViewCellOffset
            })
            .disposed(by: bag)
    }
    
    private func updateSearchBarHeight() {
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

// MARK: - Table View Delegate

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
}

// MARK: - Table View Datasource

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
