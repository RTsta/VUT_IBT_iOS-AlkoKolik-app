//
//  ProfileVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 03.03.2021.
//

import UIKit
import Charts

class ProfileVC: UITableViewController, ChartViewDelegate {
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var currentBACLabel: UILabel!
    @IBOutlet weak var peakBACLabel: UILabel!
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var soberAtLabel: UILabel!
    
    lazy var model1 : AppModel = { return (tabBarController as? MainTabBarController)?.model}() ?? createNewAppModel()
    var timer = Timer()
    
    var currentBAC : Double = 0 { didSet{currentBACLabel.text =  "\(String(format:"%.2f", currentBAC)) ‰"} }
    var peakBAC : Double = 0 { didSet{peakBACLabel.text =  "\(String(format:"%.2f", peakBAC)) ‰"} }
    var soberDate : Date = Date() { didSet{
        if soberDate > Date(){
            soberAtLabel.isHidden = false
            soberAtLabel.text =  "\(dateFormater.string(from: soberDate))"
        } else {soberAtLabel.isHidden = true}
    }}
    
    lazy var dateFormater : DateFormatter = {
        let dateformater = DateFormatter()
        dateformater.dateStyle = .none
        dateformater.timeStyle = .short
        return dateformater
    }()
        
        
    
    var entries = [ChartDataEntry] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCharts()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentBAC = model1.currentBAC ?? 0
        self.peakBAC = model1.peakBAC ?? 0
        self.soberDate = model1.soberDate ?? Date()
        self.heightLabel.text = "\(String(format:"%.1f",model1.getHeight().converted(to: .centimeters).value)) cm"
        self.weightLabel.text = "\(String(format:"%.1f",model1.getWeight().converted(to: .kilograms).value)) kg"
        startTimer()
        refreshChart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !model1.isPersonalDataAvaibile() {
            let alert = UIAlertController(title: "Personal info", message: "Sorry, there is a problem with HelthKit. Please check app premissions on health data", preferredStyle: .alert)
            
            if let url = URL(string: "x-apple-health://") {
                if UIApplication.shared.canOpenURL(url) {
                    alert.addAction(UIAlertAction(title: "Open Health", style: UIAlertAction.Style.default) {_ in
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    })
                }
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupCharts(){
        graphView.delegate = self
        
        graphView.gridBackgroundColor = .appMin
        graphView.backgroundColor = .appGrey
        
        graphView.leftAxis.axisMaximum = 3.0
        graphView.leftAxis.axisMinimum = 0
        
        graphView.rightAxis.enabled = false
        graphView.chartDescription?.enabled = false
        graphView.legend.enabled = false
        graphView.xAxis.drawLabelsEnabled = false
    }
    
    func startTimer() {
        if timer.isValid {
            timer.invalidate()
        }
        
        let refreshInterval : TimeInterval = 60.0
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick(){
        refreshChart()
    }
    
    func refreshChart(){
        model1.simulateMultipleAlcoholModels(){
            self.graphView.xAxis.removeAllLimitLines()
            
            var graphSet = [LineChartDataSet]()
            for (key, value) in self.model1.dataSet {
                
                var gEntries = [ChartDataEntry]()
                for i in stride(from: 0, to: (value?.values.count)!, by: 1){
                    
                    gEntries.append(ChartDataEntry(x: Double(i), y: Double((value?.values[i]) ?? 0)))
                }
                graphSet.append(self.createMySet(entries: gEntries, withStyle: self.dataSetStyleFrom(rFactor: key)))
            }
            
            let data = LineChartData(dataSets: graphSet)
            self.graphView.data = data
            self.graphView.legend.enabled = true
            
            if self.model1.dataSet.keys.contains(SimulationAlcoholModel.RFactorMethod.average), let _avrg = self.model1.dataSet[.average]!{
                self.createXAxes(from: _avrg.from, to: _avrg.to)
                let intervalToCurrent = Calendar.current.dateComponents([.minute], from: _avrg.from, to: Date())
                if let timeFromZeroPoint = intervalToCurrent.minute {
                    self.graphView.setVisibleXRange(minXRange: 1 , maxXRange: 480)
                    self.graphView.centerViewTo(xValue: Double(timeFromZeroPoint), yValue: 0, axis: .left)
                }
            }
            self.graphView.notifyDataSetChanged()
            self.currentBAC = self.model1.currentBAC ?? 0
            self.peakBAC = self.model1.peakBAC ?? 0
            self.soberDate = self.model1.soberDate ?? Date()
        }
    }
    
    func createXAxes(from: Date, to: Date) {
        var tmp = from
        var counter = 0.0
        while tmp < to {
            let component = Calendar.current.dateComponents([.minute, .hour, .weekday], from: tmp)
            guard let _ = component.minute, let _ = component.hour, let _ = component.weekday else {break}
            if ( (component.minute ?? 1) % 60 ) == 0 {
                if ((component.hour ?? 1) % 24 ) == 0 {
                    let weekDayString = Calendar.current.shortWeekdaySymbols[(component.weekday!-1)%7]
                    let line = ChartLimitLine(limit: counter, label: "\(weekDayString)")
                    line.lineColor = .appSemiMax
                    graphView.xAxis.addLimitLine(line)
                } else {
                    let line = ChartLimitLine(limit: counter, label: "\(component.hour ?? 0):00")
                    line.lineColor = .appMid
                    graphView.xAxis.addLimitLine(line)
                }
            } else if Calendar.current.isDate(tmp, equalTo: Date(), toGranularity: .minute){
                let line = ChartLimitLine(limit: counter, label: NSLocalizedString("now", comment: "Now at Charts graph displaying current line"))
                line.lineColor = .appMax
                line.labelPosition = .bottomLeft
                graphView.xAxis.addLimitLine(line)
            }
            
            counter += 1
            tmp = Calendar.current.date(byAdding: .minute, value: 1, to: tmp) ?? to
        }
    }
    
    func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SettingsVC {
            vc.model1 = model1
        }
    }
    
}

private extension ProfileVC {
    enum DataSetStyle : Int{
        case classic = 0
        case average = 1
        case seidel = 2
        case forrest = 3
        case ulrich = 4
        case watson = 5
        case watsonB = 6
        
    }
    
    func dataSetStyleFrom(rFactor: SimulationAlcoholModel.RFactorMethod) -> DataSetStyle{
        switch rFactor {
        case .average:
            return DataSetStyle.average
        case .seidel:
            return DataSetStyle.seidel
        case .forrest:
            return DataSetStyle.forrest
        case .ulrich:
            return DataSetStyle.ulrich
        case .watson:
            return DataSetStyle.watson
        case .watsonB:
            return DataSetStyle.watsonB
        default:
            return DataSetStyle.classic
        }
    }
    
    
    func createMySet(entries: [ChartDataEntry], withStyle style: DataSetStyle = .classic) -> LineChartDataSet {
        let set = LineChartDataSet(entries: entries)
        switch style {
        case .seidel:
            set.drawFilledEnabled = false
            set.fillColor = .appMin
            set.colors = [.appMin]
            set.label = "Seidel"
            break
        case .forrest:
            set.drawFilledEnabled = false
            set.fillColor = .appDarkGrey
            set.colors = [.appDarkGrey]
            set.label = "Forrest"
        case .ulrich:
            set.drawFilledEnabled = false
            set.fillColor = .appMid
            set.colors = [.appMid]
            set.label = "Ulrich"
        case .watson:
            set.drawFilledEnabled = false
            set.fillColor = .appSemiMax
            set.colors = [.appSemiMax]
            set.label = "Watson"
        case .average:
            set.drawFilledEnabled = false
            set.fillColor = .appMax
            set.colors = [.appMax]
            set.label = "Average"
        default:
            let gradientColors = [UIColor.appMax.cgColor, UIColor.clear.cgColor] as CFArray
            let gradient = CGGradient.init(colorsSpace: nil, colors: gradientColors, locations: nil) // Gradient Object
            set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
            set.drawFilledEnabled = true
            set.fillColor = .appMax
            set.colors = [.appMax]
            
        }
        set.drawValuesEnabled = false
        set.mode = .cubicBezier
        set.drawCirclesEnabled = false
        set.valueTextColor = .white
        return set
    }
}
