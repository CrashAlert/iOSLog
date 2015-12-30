//
//  ViewController.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import CoreMotion

class MotionLogger {
// CLASS VARIABLES
    static let sharedInstance = MotionLogger()
    
   
// INSTANCE VARIABLES
    let motionManager = CMMotionManager()
    let gyroUpdateInterval = 0.2
    let accUpdateInterval = 0.2
    
    init() {
        // configure motion manager
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        motionManager.accelerometerUpdateInterval = accUpdateInterval
        
        NSLog("\(motionManager)")
    }
    
    func start() {
        NSLog("Start Motion Manager")
        self.startAccelerationLog();
    }
    
    func startAccelerationLog() {
        NSLog("Start Acceleration Logging")
        
        if (!motionManager.accelerometerAvailable) {
            NSLog("Accelerometer not available!")
            return
        }
        
        motionManager.startAccelerometerUpdates()
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.logAccelerationData(accelerometerData!.acceleration)
            if (NSError != nil) {
                print("\(NSError)")
            }
        }
    }
    
//    func startGyroLog() {
//        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!) {
//            
//        }
//    }
    
    func stopAccelerationLog() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func stop() {
        
    }
    
    func logAccelerationData(acceleration: CMAcceleration) {
        let strX = String(format: "%.10f", acceleration.x)
        let strY = String(format: "%.10f", acceleration.y)
        let strZ = String(format: "%.10f", acceleration.z)
     
        
    }
}

import UIKit

class ViewController: UIViewController {

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


}

