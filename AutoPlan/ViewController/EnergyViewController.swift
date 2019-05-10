//
//  EnergyViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import AAInfographics
import CoreData

class EnergyViewController: UIViewController {
    
    let context = AppDelegate.viewContext
    var actions = [Action]()
    
    private var chartType: AAChartType?
    private var step: Bool?
    private var aaChartView: AAChartView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartType = .column
        step = true
        setUpTheAAChartView()
        setUpSegmentedControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request: NSFetchRequest<Action> = Action.fetchRequest()
        actions = try! context.fetch(request)
        
        var aaChartModel = AAChartModel()
            .chartType(chartType!)//图形类型
            .polar(true)
            .title("")
            .dataLabelEnabled(false)//是否显示数字
            .animationType(.bounce)//图形渲染动画类型为"bounce"
        
        var chartModelData = [[String : Any]]()
        
        var taskSet = Set<Task>()
        for action in actions {
            taskSet.insert(action.task!)
        }
        
        for task in taskSet {
            var data = Array(repeating: 0, count: 24*60/5)
            let actions = task.actions as? Set<Action>
            let calendar = Calendar.current
            for action in actions! {
                let dateComponents = calendar.dateComponents(in: calendar.timeZone, from: action.doneTime!)
                let end = (dateComponents.hour! * 60 + dateComponents.minute!) / 5
                let begin = end - Int(action.costMinutes/5)
                for i in begin...end {
                    data[i] = Int(action.energyLevel)
                }
            }
            let color = task.project?.color as? UIColor ?? UIColor.blue
            let element = AASeriesElement()
            element.name(task.title!)
            element.color(color.hexString!)
            element.data(data)
            chartModelData.append(element.toDic()!)
        }
        
        aaChartModel = aaChartModel.series(chartModelData)
        
        aaChartView?.aa_drawChartWithChartModel(aaChartModel)
    }
    
    func setUpTheAAChartView() {
        let chartViewWidth  = view.frame.size.width
        let chartViewHeight = view.frame.size.height - 220
        
        aaChartView = AAChartView()
        aaChartView?.frame = CGRect(x: 0,
                                    y: 120,
                                    width: chartViewWidth,
                                    height: chartViewHeight)
        ///AAChartViewd的内容高度(内容高度默认和 AAChartView 等高)
        aaChartView?.contentHeight = chartViewHeight - 20
        aaChartView?.scrollEnabled = false
        view.addSubview(aaChartView!)
    }
    
    func setUpSegmentedControls() {
        let segmentedNamesArray = ["Today", "Last 7 days"];
        
        let segment = UISegmentedControl.init(items: segmentedNamesArray)
        segment.frame = CGRect(x: 20,
                               y: 80.0,
                               width: view.frame.size.width - 40,
                               height: 30)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self,
                          action: #selector(segmentDidSelected(segmentedControl:)),
                          for: .valueChanged)
        view.addSubview(segment)
    }
    
    @objc func segmentDidSelected(segmentedControl:UISegmentedControl) {
        aaChartView?.aa_hideTheSeriesElementContentWithSeriesElementIndex(segmentedControl.selectedSegmentIndex)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
