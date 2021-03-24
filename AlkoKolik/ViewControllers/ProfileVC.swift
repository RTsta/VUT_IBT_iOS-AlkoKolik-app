//
//  ProfileVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 03.03.2021.
//

import UIKit
import HealthKit
import Charts

class ProfileVC: UITableViewController, ChartViewDelegate {
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var currentBACLabel: UILabel!
    @IBOutlet weak var graphView: LineChartView!
    
    let model = AlcoholModel()
    var timer = Timer()
    
    let from = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
    let to = Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
    
    var personalData : AlcoholModel.PersonalData?
    
    var currentBAC : Double = 0 { didSet{currentBACLabel.text =  " \(String(format:"%.2f", currentBAC)) ‰"} }
    
    var entries = [ChartDataEntry] ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCharts()
        createXAxes()
        loadPersonalData(){
            if let _personalData = self.personalData {
                self.heightLabel.text = "\(String(format:"%.0f",_personalData.height.converted(to: .centimeters).value)) cm"
                self.weightLabel.text = "\(String(format:"%.1f",_personalData.weight.converted(to: .kilograms).value)) kg"
            }
            self.simulateAlcoholModel()
            self.startTimer()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresChart()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

    func loadPersonalData(complition: @escaping ()->Void ) {
        HealthKitManager.getPersonalData(){ _h, _w, _a, _s in
            guard let _ = _w,
                  let _ = _h,
                  let _ = _a,
                  let _ = _s
            else {return}
            self.personalData = AlcoholModel.PersonalData(sex: _s!, height: _h!, weight: _w!, age: _a!)
            complition()
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

        
    }
    
    func createXAxes() {
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
                let line = ChartLimitLine(limit: counter, label: "now")
                line.lineColor = .appMax
                graphView.xAxis.addLimitLine(line)
            }
            
            counter += 1
            tmp = Calendar.current.date(byAdding: .minute, value: 1, to: tmp) ?? to
        }
    }
    
    func simulateAlcoholModel(){
        guard let _ = personalData else { return }
        let intervalToCurrent = Calendar.current.dateComponents([.minute], from: from, to: Date())
        model.run(personalData: personalData!, from: from, to: to) { graphInputs, succes in
            if succes, let _graphinputs = graphInputs{
                for i in stride(from: 0, to: _graphinputs.count, by: 1){
                    self.entries.append(ChartDataEntry(x: Double(i), y: _graphinputs[i]))
                }
                
                let data = LineChartData(dataSet: createSet(entries: entries))
                self.graphView.data = data
                if let timeFromZeroPoint = intervalToCurrent.minute {
                    graphView.setVisibleXRange(minXRange: 1 , maxXRange: 480)
                    graphView.centerViewTo(xValue: Double(timeFromZeroPoint), yValue: 0, axis: .left)
                }
                if (0 <= (intervalToCurrent.minute ?? -1)) && ((intervalToCurrent.minute ?? 0) < _graphinputs.count) {
                    currentBAC = _graphinputs[intervalToCurrent.minute!]
                }
                self.graphView.notifyDataSetChanged()
            }
        }
    }
    
    func createSet(entries: [ChartDataEntry]) -> LineChartDataSet {
        let set = LineChartDataSet(entries: entries)
        
        let gradientColors = [UIColor.appMax.cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient.init(colorsSpace: nil, colors: gradientColors, locations: nil) // Gradient Object
        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        set.drawFilledEnabled = true
        
        set.drawCirclesEnabled = false
        set.valueTextColor = .white
        set.fillColor = .appMax
        set.mode = .cubicBezier
        set.colors = [.appMax]
        set.drawValuesEnabled = false
        return set
    }
    
    func startTimer() {
        if timer.isValid {
            timer.invalidate()
        }
        
        let refreshInterval : TimeInterval = 60.0
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick(){
        refresChart()
    }
    
    func refresChart(){
        graphView.xAxis.removeAllLimitLines()
        createXAxes()
        simulateAlcoholModel()
    }
    
}
