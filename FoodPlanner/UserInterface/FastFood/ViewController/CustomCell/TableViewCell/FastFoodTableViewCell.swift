import UIKit

class FastFoodTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let collectionViewCellNibName = "FastFoodCollectionViewCell"
        static let collectionViewCellReuseIdentifier = "FastFoodCell"
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib(nibName: Constants.collectionViewCellNibName, bundle: .main), forCellWithReuseIdentifier: Constants.collectionViewCellReuseIdentifier)
        }
    }

    var cellViewModel: Restaurant!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension FastFoodTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentImage = UIImage(data: cellViewModel.foods[indexPath.row].imageData!)!
        
        let minimumWidth = CGFloat(200.0)
        let correctedWidth = currentImage.size.width + 20 > minimumWidth ? currentImage.size.width + 20 : minimumWidth
        
        return CGSize(width: correctedWidth, height: self.contentView.frame.size.height)
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
            cell.configureCell(with: item.imageData!)
            cell.fastFoodLabel.text = currentItem!.title
        }
        return cell
    }
}
