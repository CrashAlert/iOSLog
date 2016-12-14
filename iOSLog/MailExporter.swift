//
//  Exporter.swift
//  iOSLog
//
//  Created by Willi Raschkowski on 10/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation
import MessageUI

class MailExporter {
    static let DEFAULT_RECIPIENT = "ringnico@web.de"
    static let DEFAULT_SUBJECT = "iOSLog - Export"
    static let sharedInstance = MailExporter()
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
            
            self.delegate!.present(alert, animated: true, completion: nil)
        } else if let callback = then {
            callback()
        }
    }
    
    func sendMail() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self.delegate
        mailComposer.setToRecipients([MailExporter.DEFAULT_RECIPIENT])
        mailComposer.setSubject(MailExporter.DEFAULT_SUBJECT)
        addAttachments(mailComposer)
        
        self.delegate!.present(mailComposer, animated: true, completion: nil)
    }
    
    func addAttachments(_ mailComposer: MFMailComposeViewController) {
        let sessions = DataLog.getSessions()
        sessions.forEach { addAttachment(mailComposer, session: $0) }
    }
    
    func addAttachment(_ mailComposer: MFMailComposeViewController, session: Session) {
        // get time
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy@HH:mm"
        let dateString = formatter.string(from: date)
        
        let name = session.sessionName
        
        // time for filename
        let formatterForName = DateFormatter()
        formatterForName.dateFormat = "yyyyMMddHHmmss"
        let dateName = formatterForName.string(from: date)
        
        let data = DataLog.toCSV(session)
        mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(dateName)-\(name)-ios.csv")
    }
}
