//
//  ViewController.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//


import UIKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("view did load")
        // Do any additional setup after loading the view, typically from a nib.
        
        MotionLogger.sharedInstance.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    @IBAction func sendMail(sender: AnyObject) {
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            //Set the subject and message of the email
            mailComposer.setSubject("[Test Drive]")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
                
            let data = DataLog.sharedInstance.logData()
            mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "test.csv")
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }

}