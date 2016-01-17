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

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var sessionName: UITextField!
    var chartViewController: ChartViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartViewController = self.childViewControllers.first as? ChartViewController
        reset()
        MotionLogger.sharedInstance.start()
        Exporter.sharedInsance.delegate = self
        
        NSTimer.scheduledTimerWithTimeInterval(0.04, target: self, selector: "updateChart", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sessionName.resignFirstResponder()
    }


    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        let success = Exporter.sharedInsance.export(sessionName.text!)
        print("Export ended with response: \(success)")
        if success {
            self.reset()
        }
    }
    
    //
    // RESET
    //
    func updateDateLabel() {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.stringFromDate(date)
        self.time.text = dateString
    }
    
    @IBAction func reset() {
        self.updateChart()
        DataLog.sharedInstance.clear()
        self.updateDateLabel()
    }
    
    func updateChart() {
        let logs = DataLog.sharedInstance.logs
        var accelerationLogs = logs.filter() { $0.acceleration != nil }
        if accelerationLogs.isEmpty { return }
        let t0 = accelerationLogs[0].timestamp
        let t = accelerationLogs.last!.timestamp
        accelerationLogs = accelerationLogs.filter() { t - $0.timestamp < 1e10 } // use only last  
        let accelerationValues = accelerationLogs.map() { sqrt(pow($0.acceleration!.x, 2) + pow($0.acceleration!.y, 2) + pow($0.acceleration!.z, 2)) }
        let timestamps = accelerationLogs.map() {
            return String(format: "%.0fs", ($0.timestamp - t0)/1e9)
        }
        self.chartViewController!.updateChart(timestamps, values: accelerationValues)
    }
}