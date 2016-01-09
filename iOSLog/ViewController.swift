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

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var sessionName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("view did load")
        // Do any additional setup after loading the view, typically from a nib.
        
        reset() 
        MotionLogger.sharedInstance.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sessionName.resignFirstResponder()
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