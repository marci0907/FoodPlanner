import Charts
import RxSwift
import UIKit

class FastFoodDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fastFoodImage: UIImageView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var bag = DisposeBag()
    var completionHandlerAfterDismiss: () -> Void = {}
    var longPressGesture: UILongPressGestureRecognizer!
    var viewModel: FastFoodDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLongPressGesture()
        updateUI()
        
        viewModel.getDetailsForSelectedFood().asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [unowned self] fastFoodModel in
                self.fastFoodImage.image = UIImage(data: self.viewModel.selectedFood.imageData!)
                self.titleLabel.text = fastFoodModel.title
                self.setupPieChart(withData: fastFoodModel)
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(longPressGesture)
        longPressGesture.delegate = nil
    }
    
    // FIXME: move this code to viewmodel
    
    private func setupPieChart(withData data: FastFoodDetailModel) {
        let carbsAmount = Double(data.nutrition.carbs.dropLast())!
        let proteinAmount = Double(data.nutrition.protein.dropLast())!
        let fatAmount = Double(data.nutrition.fat.dropLast())!
        let sumOfNutrients = carbsAmount + proteinAmount + fatAmount
        let chartDataEntries = [
            PieChartDataEntry(value: carbsAmount / sumOfNutrients,
                              label: "\(data.nutrition.carbs)"),
            PieChartDataEntry(value: proteinAmount / sumOfNutrients,
                              label: "\(data.nutrition.protein)"),
            PieChartDataEntry(value: fatAmount / sumOfNutrients,
                              label: "\(data.nutrition.fat)"),
        ]
        
        let chartDataSet = PieChartDataSet(entries: chartDataEntries)
        let blue = UIColor(red: 71/255, green: 98/255, blue: 168/255, alpha: 1)
        let green = UIColor(red: 159/255, green: 198/255, blue: 100/255, alpha: 1)
        let red = UIColor(red: 211/255, green: 80/255, blue: 75/255, alpha: 1)
        chartDataSet.colors = [blue, green, red]
        chartDataSet.automaticallyDisableSliceSpacing = true
        chartDataSet.sliceSpace = 5
        chartDataSet.yValuePosition = .outsideSlice
        chartDataSet.valueLineColor = .clear
        
        let legendEntries = [
            LegendEntry(label: "Carbs", form: .circle, formSize: CGFloat(8), formLineWidth: CGFloat(2), formLineDashPhase: CGFloat(2), formLineDashLengths: nil, formColor: blue),
            LegendEntry(label: "Protein", form: .circle, formSize: CGFloat(8), formLineWidth: CGFloat(2), formLineDashPhase: CGFloat(2), formLineDashLengths: nil, formColor: green),
            LegendEntry(label: "Fat", form: .circle, formSize: CGFloat(8), formLineWidth: CGFloat(2), formLineDashPhase: CGFloat(2), formLineDashLengths: nil, formColor: red)
        ]
        pieChart.legend.setCustom(entries: legendEntries)
        pieChart.legend.horizontalAlignment = .center
        pieChart.legend.textColor = .black
        
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData
        pieChart.centerText = "\(data.nutrition.calories) kcal"
        pieChart.animate(xAxisDuration: 0.4, easingOption: .easeInQuad)
        
    }
    
    private func updateUI() {
        containerView.layer.cornerRadius = 10.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowRadius = 5
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.insertSubview(blurEffectView, belowSubview: containerView)
    }
    
    private func setLongPressGesture() {
        longPressGesture.removeTarget(nil, action: nil)
        longPressGesture.addTarget(self, action: #selector(longPressed(recognizer:)))
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .ended, .cancelled:
            self.dismiss(animated: true, completion: completionHandlerAfterDismiss)
        default:
            break
        }
    }
    
    func addRecognizer(recognizer: UILongPressGestureRecognizer) {
        self.longPressGesture = recognizer
    }

}
