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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sessionName.resignFirstResponder()
    }
    
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

    @IBAction func sendMail(sender: AnyObject) {
        let name = sessionName.text!
        if name.isEmpty {
            let alert = UIAlertView(
                title: "No Session Name",
                message: "Fill in a session name.",
                delegate: nil,
                cancelButtonTitle: "OK"
            )
            alert.show()
            return
        }
        
        
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
            mailComposer.setSubject("[\(dateString)] \(name) - Test drive")
            
            // Time for filename
            let formatterForName = NSDateFormatter()
            formatterForName.dateFormat = "yyyyMMddHHmmss"
            let dateName = formatterForName.stringFromDate(date)
            
            let data = DataLog.sharedInstance.csvData()
            mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(dateName)-\(name)-ios.csv")
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func reset() {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.stringFromDate(date)
        time.text = dateString
        DataLog.sharedInstance.clear()
    }
}