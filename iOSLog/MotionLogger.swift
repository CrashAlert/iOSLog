//
//  CoreMotionDelegate.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import CoreMotion
import CoreLocation


class MotionLogger: NSObject, CLLocationManagerDelegate  {
    // == CLASS VARIABLES ==
    static let sharedInstance = MotionLogger()
    
    
    // == INSTANCE VARIABLES ==
    
    // Motion Manager
    let motionManager = CMMotionManager()
    let gyroUpdateInterval = 0.1
    let accUpdateInterval = 0.1
    
    // Location Manager
    let locationManager = CLLocationManager()
    let locationAccuracy = kCLLocationAccuracyBest
    
    override init() {
        super.init()
        
        // configure motion manager
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        motionManager.accelerometerUpdateInterval = accUpdateInterval
        
        // configure location manager
        locationManager.desiredAccuracy = locationAccuracy
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func start() {
        NSLog("Start Motion Manager")
        self.startAccelerationLog()
        self.startGyroLog()
        self.startGPSLog()
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
    
    func startGPSLog() {
        NSLog("Start GPS Log")
        
        if (!CLLocationManager.locationServicesEnabled()) {
            NSLog("GPS not available!")
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
            // this only happens when location services were not enabled in startGPSLog before
            self.startGPSLog()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let sensorData = SensorData(timestamp: location.timestamp, location: location)
            DataLog.sharedInstance.addSensorData(sensorData)
        }
    }
    
    func logAccelerationData(acceleration: CMAcceleration) {
        let sensorData = SensorData(acceleration: acceleration)
        
        // Log data to buffer
        DataLog.sharedInstance.addSensorData(sensorData)
        
        // Update viewcontroller observer
        // ...
    }
    
    func logGyroData(gyro: CMRotationRate) {
        let sensorData = SensorData(rotationRate: gyro)
        DataLog.sharedInstance.addSensorData(sensorData)
    }
    
    func stopAccelerationLog() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func stopGyroLog() {
        motionManager.stopGyroUpdates()
    }
    
    func stopGPSLog() {
        locationManager.stopUpdatingLocation()
    }
    
    func stop() {
        self.stopAccelerationLog()
        self.stopGyroLog()
        self.stopGPSLog()
    }
}