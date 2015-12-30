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
                
            if let fileData = logData() {
                print("File data loaded.")
                mailComposer.addAttachmentData(fileData, mimeType: "text/csv", fileName: "test.csv")
            }
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    @IBAction func export(sender: AnyObject) {
        let fileManager = NSFileManager.defaultManager()
        let tmpDir = NSTemporaryDirectory()
        let fileName = "test.csv"
        let path = tmpDir + fileName
        let contents = "No,President Name,Wikipedia URL,Took office,Left office,Party,Home State\n1,George Washington,http://en.wikipedia.org/wiki/George_Washington,30/04/1789,4/03/1797,Independent,Virginia\n2,John Adams,http://en.wikipedia.org/wiki/John_Adams,4/03/1797,4/03/1801,Federalist,Massachusetts\n3,Thomas Jefferson,http://en.wikipedia.org/wiki/Thomas_Jefferson,4/03/1801,4/03/1809,Democratic-Republican,Virginia\n4,James Madison,http://en.wikipedia.org/wiki/James_Madison,4/03/1809,4/03/1817,Democratic-Republican,Virginia\n5,James Monroe,http://en.wikipedia.org/wiki/James_Monroe,4/03/1817,4/03/1825,Democratic-Republican,Virginia\n6,John Quincy Adams,http://en.wikipedia.org/wiki/John_Quincy_Adams,4/03/1825,4/03/1829,Democratic-Republican/National Republican,Massachusetts"
        
        let data = contents.dataUsingEncoding(NSUTF8StringEncoding)
        fileManager.createFileAtPath(path, contents: data, attributes: nil)
        let url = NSURL(fileURLWithPath: path)
        let docController = UIDocumentInteractionController(URL: url)
        docController.UTI = "public.comma-separated-values-text"
        docController.delegate = self
        let response = docController.presentOptionsMenuFromBarButtonItem(sender as! UIBarButtonItem, animated: true)
        print("\(response)")
        //        do {
        ////            fileManager.createFileAtPath(path, contents: NSData?, attributes: <#T##[String : AnyObject]?#>)
        //            try contents.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        //            print("Wrote .csv to \(path).")
        //
        //            let url = NSURL(fileURLWithPath: path)
        //            let docController = UIDocumentInteractionController(URL: url)
        //            docController.UTI = "public.comma-separated-values-text"
        //            docController.delegate = self
        //            let response = docController.presentOptionsMenuFromBarButtonItem(sender as! UIBarButtonItem, animated: true)
        //            print("\(response)")
        //        } catch {
        //            print("Nope.")
        //        }
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logData() -> NSData? {
        let contents = "No,President Name,Wikipedia URL,Took office,Left office,Party,Home State\n1,George Washington,http://en.wikipedia.org/wiki/George_Washington,30/04/1789,4/03/1797,Independent,Virginia\n2,John Adams,http://en.wikipedia.org/wiki/John_Adams,4/03/1797,4/03/1801,Federalist,Massachusetts\n3,Thomas Jefferson,http://en.wikipedia.org/wiki/Thomas_Jefferson,4/03/1801,4/03/1809,Democratic-Republican,Virginia\n4,James Madison,http://en.wikipedia.org/wiki/James_Madison,4/03/1809,4/03/1817,Democratic-Republican,Virginia\n5,James Monroe,http://en.wikipedia.org/wiki/James_Monroe,4/03/1817,4/03/1825,Democratic-Republican,Virginia\n6,John Quincy Adams,http://en.wikipedia.org/wiki/John_Quincy_Adams,4/03/1825,4/03/1829,Democratic-Republican/National Republican,Massachusetts"
        
        return contents.dataUsingEncoding(NSUTF8StringEncoding)!
    }

}