//
//  Exporter.swift
//  iOSLog
//
//  Created by Willi Raschkowski on 10/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation
import MessageUI

class Exporter {
    
    static let sharedInsance = Exporter()
    var delegate: ViewController?
    
    init() {
        
    }
    
    func export(sessionName: String) -> Bool {
        // TODO: Why Wifi Alert?
        
        if sessionName.isEmpty {
            self.showSessionAlert()
        } else if MFMailComposeViewController.canSendMail() {
            self.sendMail(sessionName)
            return true
        }
        return false
    }
    
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
            
            self.delegate!.presentViewController(alert, animated: true, completion: nil)
        } else if let callback = then {
            callback()
        }
    }
    
    func showSessionAlert(then: ((Void) -> Void)? = nil) {
        let alert = UIAlertView(
            title: "No Session Name",
            message: "Fill in a session name.",
            delegate: nil,
            cancelButtonTitle: "OK")
        alert.show()
    }
    
    func sendMail(sessionName: String) {
        NSLog("Sent \(DataLog.sharedInstance.logs.count) rows of data")
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self.delegate
        
        // Get time
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy@HH:mm"
        let dateString = formatter.stringFromDate(date)
        
        // Set the subject of the email
        let name = sessionName
        mailComposer.setSubject("[\(dateString)] \(name) - Test drive")
        
        // Time for filename
        let formatterForName = NSDateFormatter()
        formatterForName.dateFormat = "yyyyMMddHHmmss"
        let dateName = formatterForName.stringFromDate(date)
        
        let data = DataLog.sharedInstance.csvData()
        mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(dateName)-\(name)-ios.csv")
        
        self.delegate!.presentViewController(mailComposer, animated: true, completion: nil)
    }
}