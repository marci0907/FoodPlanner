import RxCocoa
import RxSwift
import UIKit

class CustomSlider: UISlider {

    private enum Constants {
        static let maxKcal: Float = 2000
        static let maxCarb: Float = 200
        static let maxProtein: Float = 200
        static let maxFat: Float = 200
        static let maxNumberOfItems: Float = 100
    }

    enum SliderType {
        case kcal
        case carb
        case protein
        case fat
        case numberOfItems
    }

    private var bag = DisposeBag()
    private var label = UILabel()
    private var type: SliderType!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(forType type: SliderType) {
        self.init()
        self.type = type
        setup()
    }

    override func layoutSubviews() {
        label.frame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(label)
    }

    private func setup() {
        switch type {
        case .kcal:
            self.maximumValue = Constants.maxKcal
            self.value = QuerySettings.maxKcalAmountQuery
            label.text = "\(QuerySettings.maxKcalAmountQuery)"
        case .carb:
            self.maximumValue = Constants.maxCarb
            self.value = QuerySettings.maxCarbsAmountQuery
            label.text = "\(QuerySettings.maxCarbsAmountQuery)"
        case .protein:
            self.maximumValue = Constants.maxProtein
            self.value = QuerySettings.maxProteinAmountQuery
            label.text = "\(QuerySettings.maxProteinAmountQuery)"
        case .fat:
            self.maximumValue = Constants.maxFat
            self.value = QuerySettings.maxFatAmountQuery
            label.text = "\(QuerySettings.maxFatAmountQuery)"
        case .numberOfItems:
            self.maximumValue = Constants.maxNumberOfItems
            self.value = QuerySettings.maxNumberOfItems
            label.text = "\(QuerySettings.maxNumberOfItems)"
        default:
            break
        }

        self.rx.value.asObservable()
            .subscribe(onNext: { currentValue in
                switch self.type {
                case .kcal:
                    QuerySettings.maxKcalAmountQuery = currentValue
                case .carb:
                    QuerySettings.maxCarbsAmountQuery = currentValue
                case .protein:
                    QuerySettings.maxProteinAmountQuery = currentValue
                case .fat:
                    QuerySettings.maxFatAmountQuery = currentValue
                case .numberOfItems:
                    QuerySettings.maxNumberOfItems = currentValue
                default:
                    break
                }
            })
            .disposed(by: bag)
    }

}
