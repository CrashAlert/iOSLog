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
    static let DEFAULT_RECIPIENT = "sven.mkw@gmail.com"
    static let DEFAULT_SUBJECT = "iOSLog - Export"
    static let sharedInstance = Exporter()
    var delegate: ViewController?
    
    init() {
        
    }
    
    func export() -> Bool {
        // TODO: Wifi Alert
        
        if MFMailComposeViewController.canSendMail() {
            self.sendMail()
            return true
        }
        return false
    }
    
    func clear() {
        NSLog("Deleting \(DataLog.getSessions().count) session objects.")
        DataLog.getSessions().forEach { DataLog.clear($0) }
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
    
    func sendMail() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self.delegate
        mailComposer.setToRecipients([Exporter.DEFAULT_RECIPIENT])
        mailComposer.setSubject(Exporter.DEFAULT_SUBJECT)
        addAttachments(mailComposer)
        
        self.delegate!.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func addAttachments(mailComposer: MFMailComposeViewController) {
        let sessions = DataLog.getSessions()
        sessions.forEach { addAttachment(mailComposer, session: $0) }
    }
    
    func addAttachment(mailComposer: MFMailComposeViewController, session: Session) {
        // get time
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy@HH:mm"
        let dateString = formatter.stringFromDate(date)
        
        let name = session.sessionName
        
        // time for filename
        let formatterForName = NSDateFormatter()
        formatterForName.dateFormat = "yyyyMMddHHmmss"
        let dateName = formatterForName.stringFromDate(date)
        
        let data = DataLog.toCSV(session)
        mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(dateName)-\(name)-ios.csv")
    }
}