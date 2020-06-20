import UIKit

class FastFoodCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fastFoodImage: UIImageView!
    @IBOutlet weak var fastFoodLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with image: Data) {
        fastFoodImage?.image = UIImage(data: image)
        fastFoodImage.layer.cornerRadius = 10.0
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 5
    }
}
