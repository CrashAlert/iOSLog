//
//  ChartViewController.swift
//  iOSLog
//
//  Created by Willi Raschkowski on 10/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import UIKit
import Charts
import Foundation

class ChartViewController: UIViewController {
    
    @IBOutlet weak var chart: LineChartView!
    override func viewDidLoad() {
        intializeChart()
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        updateChart(months, values: unitsSold)
    }
    
    func intializeChart() {
        // Setup
        chart.descriptionText = ""
        chart.noDataText = "Kein Limit; kein Limit; Bitch, ich kenne kein Limit."
        chart.legend.enabled = false
        chart.xAxis.labelPosition = .Bottom
        
        // Turn off grid lines
        chart.xAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = true
        
        // Turn off axis lines
        chart.xAxis.drawAxisLineEnabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.xAxis.enabled = true
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = true
        chart.rightAxis.drawAxisLineEnabled = false
        
//        chart.rightAxis.valueFormatter = gFormatter()
        
        // Background
        chart.drawGridBackgroundEnabled = false
        
        // Interaction
        chart.userInteractionEnabled = false
    }
    
    func updateChart(dataPoints: [String], values: [Double]) {
        let dataEntries = values.enumerate().map { ChartDataEntry(value: $1, xIndex: $0) }
        
        let dataSet = LineChartDataSet(yVals: dataEntries)
        dataSet.drawCirclesEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.drawValuesEnabled = false
        
        let data = LineChartData(xVals: dataPoints, dataSet: dataSet)
        chart.data = data
    }
}

class gFormatter: NSNumberFormatter {
    
    override func stringFromNumber(number: NSNumber) -> String? {
        // TODO: Slice out first characters
        return String(number)      
    }
    
}