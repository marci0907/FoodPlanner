import Charts
import Foundation
import RxSwift

final class FastFoodDetailViewModel {
    
    private typealias service = FastFoodDetailService
    
    var selectedFood: FastFoodModel
    
    init(selectedFood: FastFoodModel) {
        self.selectedFood = selectedFood
    }
    
    func getDetailsForSelectedFood() -> Single<FastFoodDetailModel> {
        return service().getDetails(for: selectedFood)
    }
    
    func setup(_ pieChart: PieChartView, with data: FastFoodDetailModel) {
        let carbsAmount = Double(data.nutrition.carbs.dropLast())!
        let proteinAmount = Double(data.nutrition.protein.dropLast())!
        let fatAmount = Double(data.nutrition.fat.dropLast())!
        let nutrientArray: [Nutrient] = [
            Nutrient(title: "\(Int(carbsAmount))g", amount: carbsAmount, unit: ""),
            Nutrient(title: "\(Int(proteinAmount))g", amount: proteinAmount, unit: ""),
            Nutrient(title: "\(Int(fatAmount))g", amount: fatAmount, unit: "")
        ]
        let sumOfNutrients = carbsAmount + proteinAmount + fatAmount
        
        var chartDataEntries = [PieChartDataEntry]()
        nutrientArray.forEach { nutrient in
            if nutrient.amount > 0 {
                let newPieChartEntry = PieChartDataEntry(value: nutrient.amount / sumOfNutrients,
                                                         label: nutrient.title)
                chartDataEntries.append(newPieChartEntry)
            }
        }
        
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
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let centerText = NSAttributedString(string: "\(Int(data.nutrition.calories)) kcal", attributes: attributes)
        pieChart.centerAttributedText = centerText
        
        pieChart.animate(xAxisDuration: 0.4, easingOption: .easeInQuad)
    }
}
