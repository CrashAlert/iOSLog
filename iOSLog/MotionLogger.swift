//
//  CoreMotionDelegate.swift
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
    let gyroUpdateInterval = 0.1
    let accUpdateInterval = 0.1
    
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
    
    func startGyroLog() {
        NSLog("Start Gyro Logging")
        
        if (!motionManager.gyroAvailable) {
            NSLog("Gyro not available!")
            return
        }
        
        motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (gyroData: CMGyroData?, NSError) -> Void in
            self.logGyroData(gyroData!.rotationRate)
            if (NSError != nil) {
                print("\(NSError)")
            }
        }
    }
    
    func stopAccelerationLog() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func stopGyroLog() {
        motionManager.stopGyroUpdates()
    }
    
    func stop() {
        self.stopAccelerationLog()
        self.stopGyroLog()
    }
    
    func logAccelerationData(acceleration: CMAcceleration) {
        let strX = String(format: "%.10f", acceleration.x)
        let strY = String(format: "%.10f", acceleration.y)
        let strZ = String(format: "%.10f", acceleration.z)
        
        // ... log
    }
    
    func logGyroData(gyro: CMRotationRate) {
        let strX = String(format: "%.10f", gyro.x)
        let strY = String(format: "%.10f", gyro.y)
        let strZ = String(format: "%.10f", gyro.z)
        
        // ... log
    }
}