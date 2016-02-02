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


class ViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate {
    static let unexportedLabelTemplate = "You currently have %d unexported logs."
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet var startButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var discardButton: UIBarButtonItem!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sessionName: UITextField!
    @IBOutlet weak var unexportedLabel: UILabel!
    var logger: MotionLogger? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // update UIs
        hideButton(saveButton)
        hideButton(discardButton)
        hideTime()
        updateUnexportedLabel()
        
        reset()
        Exporter.sharedInstance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sessionName.resignFirstResponder()
    }
    
    
    //
    // LOGGING
    //
    
    /*
     * Start tracking data.
     */
    @IBAction func startLogging(sender: AnyObject) {
        if (sessionName.text!.isEmpty || sessionExists()) {
            showSessionAlert()
            return
        }
        
        // update UI
        hideButton(startButton)
        showButton(discardButton)
        showButton(saveButton)
        showTime()
        updateTime()
        lockSessionName()
        
        logger = MotionLogger(sessionName: sessionName.text!, withCrashAlerter: true) // always with crash alerter enabled
        logger!.start()
    }
    
    /*
     * Stop tracking data and save session persistantly.
     */
    @IBAction func saveLogging(sender: AnyObject) {
        NSLog("Save Logging")
        logger!.stop()
        
        // update UI
        hideButton(discardButton)
        hideButton(saveButton)
        showButton(startButton)
        hideTime()
        unlockSessionName()
        updateUnexportedLabel()
    }
    
    /*
     * Stop Logging without saving changes. Show an alert box before.
     */
    @IBAction func discardLogging(sender: AnyObject) {
        let sessionName = self.sessionName.text!
        saveLogging(sender)
        
        // delete the recently recorded session
        let session = DataLog.getSessions().filter("sessionName = %@", sessionName).first!
        DataLog.clear(session)
        
        updateUnexportedLabel()
    }
    
    
    //
    // EXPORT
    //
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // delete stored data only, when mail was successfully sent
        if (result == MFMailComposeResultSent) {
            Exporter.sharedInstance.clear()
            updateUnexportedLabel()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        let success = Exporter.sharedInstance.export()
        NSLog("Export ended with response: \(success)")
        if success {
            self.reset()
        }
    }

    
    //
    // ALERTS
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
    
    func showSessionAlert() {
        let alert = UIAlertView(
            title: "No Session Name or Session Name exists",
            message: "Fill in a session name.",
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    
    //
    // RESET
    //
    
    func updateTime() {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.stringFromDate(date)
        time.text = dateString
    }
    
    func resetData() {
        updateTime()
        // TODO: clear realm
        //DataLog.sharedInstance.clear()
    }
    
    @IBAction func reset() {
        resetData()
    }
    
    func sessionExists() -> Bool {
        return DataLog.getSessions().filter("sessionName = %@", sessionName.text!).count > 0
    }
    
    
    //
    // UI UPDATES
    //
    
    // http://stackoverflow.com/a/10022234/2729416
    func hideButton(button: UIBarButtonItem) {
        let index = toolbar.items?.indexOf(button)
        toolbar.items?.removeAtIndex(index!)
    }
    
    func showButton(button: UIBarButtonItem) {
        toolbar.items?.insert(button, atIndex: 1)
    }
    
    func showTime() {
        timeLabel.hidden = false
        time.hidden = false
    }
    
    func hideTime() {
        timeLabel.hidden = true
        time.hidden = true
    }
    
    func lockSessionName() {
        sessionName.enabled = false
    }
    
    func unlockSessionName() {
        sessionName.enabled = true
        sessionName.text = ""
    }
    
    func updateUnexportedLabel() {
        let logsCount = DataLog.getSessions().count
        unexportedLabel.text = String(format: ViewController.unexportedLabelTemplate, logsCount)
        
        if (logsCount == 0) {
            exportButton.enabled = false
        } else {
            exportButton.enabled = true
        }
    }
    
}