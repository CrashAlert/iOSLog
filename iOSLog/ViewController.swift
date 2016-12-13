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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sessionName.resignFirstResponder()
    }
    
    
    //
    // LOGGING
    //
    
    /*
     * Start tracking data.
     */
    @IBAction func startLogging(_ sender: AnyObject) {
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
        
        logger = MotionLogger(sessionName: sessionName.text!)
        logger?.start()
    }
    
    /*
     * Stop tracking data and save session persistantly.
     */
    @IBAction func saveLogging(_ sender: AnyObject) {
        logger?.stop()
        
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
    @IBAction func discardLogging(_ sender: AnyObject) {
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // delete stored data only, when mail was successfully sent
        if (result == MFMailComposeResult.sent) {
            Exporter.sharedInstance.clear()
            updateUnexportedLabel()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exportData(_ sender: AnyObject) {
        let success = Exporter.sharedInstance.export()
        NSLog("Export ended with response: \(success)")
        if success {
            self.reset()
        }
    }

    
    //
    // ALERTS
    //
    
    func showWifiAlert(_ then: ((Void) -> Void)? = nil) {
        if ReachabilityManager.hasConnectivity() {  
            let alert = UIAlertController(
                title: "No Wifi",
                message: "You have no Wifi connection. Really upload the data?",
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Continue", style: .default) { (UIAlertAction) -> Void in
                if let callback = then {
                    callback()
                }
            }
            alert.addAction(confirmAction)
            
            self.present(alert, animated: true, completion: nil)
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
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.string(from: date)
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
    func hideButton(_ button: UIBarButtonItem) {
        let index = toolbar.items?.index(of: button)
        toolbar.items?.remove(at: index!)
    }
    
    func showButton(_ button: UIBarButtonItem) {
        toolbar.items?.insert(button, at: 1)
    }
    
    func showTime() {
        timeLabel.isHidden = false
        time.isHidden = false
    }
    
    func hideTime() {
        timeLabel.isHidden = true
        time.isHidden = true
    }
    
    func lockSessionName() {
        sessionName.isEnabled = false
    }
    
    func unlockSessionName() {
        sessionName.isEnabled = true
        sessionName.text = ""
    }
    
    func updateUnexportedLabel() {
        let logsCount = DataLog.getSessions().count
        unexportedLabel.text = String(format: ViewController.unexportedLabelTemplate, logsCount)
        
        if (logsCount == 0) {
            exportButton.isEnabled = false
        } else {
            exportButton.isEnabled = true
        }
    }
    
}
