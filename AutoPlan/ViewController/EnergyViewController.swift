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
    
    private var chartType: AAChartType?
    private var step: Bool?
    private var aaChartView: AAChartView?
    private var aaChartModel: AAChartModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartType = .column
        step = true
        setUpTheAAChartView()
        setUpSegmentedControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawToday()
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
        aaChartModel = AAChartModel()
            .chartType(chartType!)//图形类型
            .polar(true)
            .title("")
            .dataLabelEnabled(false)//是否显示数字
            .animationType(.bounce)//图形渲染动画类型为"bounce"
        aaChartView?.aa_drawChartWithChartModel(aaChartModel!)
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
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            drawToday()
        case 1:
            let request: NSFetchRequest<Action> = Action.fetchRequest()
            let actions = try! context.fetch(request)
            var data = Array(repeating: 0, count: 24*60/5)
            var count = Array(repeating: 0, count: 24*60/5)
            for action in actions {
                if action.doneTime! < Date(), action.doneTime! > Calendar.current.date(byAdding: .day, value: -7, to: Date())! {
                    let calendar = Calendar.current
                    let dateComponents = calendar.dateComponents(in: calendar.timeZone, from: action.doneTime!)
                    let end = (dateComponents.hour! * 60 + dateComponents.minute!) / 5
                    let begin = end - Int(action.costMinutes/5)
                    for i in begin...end {
                        data[i] += Int(action.energyLevel)
                        count[i] += 1
                    }
                }
            }
            for i in 0...24*60/5-1 {
                if count[i] != 0 {
                    data[i] /= count[i]
                }
            }
            aaChartModel = aaChartModel!
                .chartType(.line)
                .series([
                    AASeriesElement()
                    .name("Average")
                    .data(data)
                    .toDic()!,
                    ])
            aaChartView?.aa_refreshChartWholeContentWithChartModel(aaChartModel!)
        default:
            break
        }
    }

    func drawToday() {
        let request: NSFetchRequest<Action> = Action.fetchRequest()
        let actions = try! context.fetch(request)
        var chartModelData = [[String : Any]]()
        
        var taskSet = Set<Task>()
        for action in actions {
            if Calendar.current.isDate(action.doneTime!, inSameDayAs: Date()) {
                taskSet.insert(action.task!)
            }
        }
        
        for task in taskSet {
            var data = Array(repeating: 0, count: 24*60/5)
            let actions = task.actions as? Set<Action>
            let calendar = Calendar.current
            for action in actions! {
                if Calendar.current.isDate(action.doneTime!, inSameDayAs: Date()) {
                    let dateComponents = calendar.dateComponents(in: calendar.timeZone, from: action.doneTime!)
                    let end = (dateComponents.hour! * 60 + dateComponents.minute!) / 5
                    let begin = end - Int(action.costMinutes/5)
                    for i in begin...end {
                        data[i] = Int(action.energyLevel)
                    }
                }
            }
            let color = task.project?.color as? UIColor ?? UIColor.blue
            let element = AASeriesElement()
            element.name(task.title!)
            element.color(color.hexString!)
            element.data(data)
            chartModelData.append(element.toDic()!)
        }
        aaChartModel = aaChartModel!.series(chartModelData).chartType(.column)
        aaChartView?.aa_refreshChartWholeContentWithChartModel(aaChartModel!)
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
