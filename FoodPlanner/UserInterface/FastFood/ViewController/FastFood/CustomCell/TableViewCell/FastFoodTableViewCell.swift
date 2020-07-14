import UIKit

class FastFoodTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let collectionViewCellNibName = "FastFoodCollectionViewCell"
        static let collectionViewCellPadding: CGFloat = 20.0
        static let collectionViewCellReuseIdentifier = "FastFoodCell"
        static let labelHeight: CGFloat = 24.0
        static let minimumCellHeight: CGFloat = 100.0
        static let minimumCellWidth: CGFloat = 200.0
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib(nibName: Constants.collectionViewCellNibName, bundle: .main), forCellWithReuseIdentifier: Constants.collectionViewCellReuseIdentifier)
        }
    }

    var cellViewModel: Restaurant!
    var collectionViewCellOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        get {
            return collectionView.contentOffset.x
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension FastFoodTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentImage = UIImage(data: cellViewModel.foods[indexPath.row].imageData!)!
        
        let correctedWidth = currentImage.size.width + Constants.collectionViewCellPadding > Constants.minimumCellWidth ? currentImage.size.width + Constants.collectionViewCellPadding : Constants.minimumCellWidth
        let correctedHeight = self.contentView.frame.size.height > Constants.minimumCellHeight ? self.contentView.frame.size.height : Constants.minimumCellHeight
        
        return CGSize(width: correctedWidth, height: correctedHeight)
    }
}

extension FastFoodTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModel?.foods.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCellReuseIdentifier, for: indexPath) as! FastFoodCollectionViewCell
        let currentItem = cellViewModel?.foods[indexPath.row]
        
        if let item = currentItem {
            cell.cellViewModel = item
        }
        return cell
    }
}
