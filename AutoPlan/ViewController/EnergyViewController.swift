//
//  EnergyViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import AAInfographics

class EnergyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAAChart()
    }
    
    func loadAAChart() {
        let chartViewWidth  = self.view.frame.size.width
        let chartViewHeight = self.view.frame.size.height
        let aaChartView = AAChartView()
        aaChartView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: chartViewWidth,
                                   height: chartViewHeight)
        // set the content height of aachartView
        // aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        
        let aaChartModel = AAChartModel()
            .chartType(.column)
            .polar(true)
            .series([
                AASeriesElement()
                    .name("Column")
                    .type(.column)
                    .data([8, 7, 6, 5, 4, 3, 2, 1, 1, 3, 4, 6, 8, 7, 6, 5, 4, 3, 2, 1, 1, 3, 4, 6])
                    .toDic()!,
                ])
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
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
