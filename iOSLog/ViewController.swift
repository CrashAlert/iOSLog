//
//  ViewController.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import Charts

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var sessionName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("view did load")
        // Do any additional setup after loading the view, typically from a nib.
        
        reset()
        MotionLogger.sharedInstance.start()
        
        intializeChart()
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        updateChart(months, values: unitsSold)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sessionName.resignFirstResponder()
    }
    
    //
    // CHART
    //
    func intializeChart() {
        // Setup
        lineChartView.descriptionText = ""
        lineChartView.noDataText = "Kein Limit; kein Limit; Bitch, ich kenne kein Limit."
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelPosition = .Bottom

        // Turn off grid lines
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        
        // Turn off axis lines
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false

        // Background
        lineChartView.drawGridBackgroundEnabled = false
    }
    
    func updateChart(dataPoints: [String], values: [Double]) {
        let dataEntries = values.enumerate().map { ChartDataEntry(value: $1, xIndex: $0) }

        let dataSet = LineChartDataSet(yVals: dataEntries)
//        chartDataSet.colors = ChartColorTemplates.pastel()
        dataSet.drawCirclesEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.drawValuesEnabled = false
        
        let data = LineChartData(xVals: dataPoints, dataSet: dataSet)
        lineChartView.data = data
//        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
//        let ll = ChartLimitLine(limit: 10.0, label: "Target")
//        lineChartView.rightAxis.addLimitLine(ll)
    }
    
    //
    // EXPORT
    //
    
    func showWifiAlert(then: ((Void) -> Void)? = nil) {
        if ReachabilityManager.hasConnectivity() {
            let alert = UIAlertController(
                title: "No Wifi",
                message: "You have no Wifi connection. Really upload the data?",
                preferredStyle: .Alert
            )
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Continue", style: .Default) { (UIAlertAction) -> Void in
                if let callback = then {
                    callback()
                }
            }
            alert.addAction(confirmAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else if let callback = then {
            callback()
        }
    }
    
    func showSessionAlert(then: ((Void) -> Void)? = nil) {
        let name = sessionName.text!
        if name.isEmpty {
            let alert = UIAlertView(
                title: "No Session Name",
                message: "Fill in a session name.",
                delegate: nil,
                cancelButtonTitle: "OK"
            )
            alert.show()
        } else if let callback = then {
            callback()
        }
    }

    func sendMail() {
        if( MFMailComposeViewController.canSendMail() ) {
            NSLog("Sent \(DataLog.sharedInstance.logs.count) rows of data")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            // Get time
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy@HH:mm"
            let dateString = formatter.stringFromDate(date)
            
            // Set the subject of the email
            let name = sessionName.text!
            mailComposer.setSubject("[\(dateString)] \(name) - Test drive")
            
            // Time for filename
            let formatterForName = NSDateFormatter()
            formatterForName.dateFormat = "yyyyMMddHHmmss"
            let dateName = formatterForName.stringFromDate(date)
            
            let data = DataLog.sharedInstance.csvData()
            mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(dateName)-\(name)-ios.csv")
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
            
            self.resetData()
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        self.showWifiAlert() {
            () -> Void in self.showSessionAlert() {
                () -> Void in self.sendMail()
            }
        }
    }
    
    
    //
    // RESET
    //
    
    func resetData() {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.stringFromDate(date)
        time.text = dateString
        DataLog.sharedInstance.clear()
    }
    
    @IBAction func reset() {
        resetData()
    }
}