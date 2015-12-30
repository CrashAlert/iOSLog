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
        if( MFMailComposeViewController.canSendMail() ) {
            print(DataLog.sharedInstance.logs.count)
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            // Get time
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy@HH:mm"
            let dateString = formatter.stringFromDate(date)
            
            // Set the subject of the email
            mailComposer.setSubject("[\(dateString)] Test drive")
            
            let data = DataLog.sharedInstance.csvData()
            mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "\(Int(NSDate().timeIntervalSince1970)).csv")
            
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