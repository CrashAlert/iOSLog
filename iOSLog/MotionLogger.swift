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
    let magUpdateInterval = 0.1
    
    // Location Manager
    let locationManager = CLLocationManager()
    let locationAccuracy = kCLLocationAccuracyBest
    
    // Motion Activity Manager
    let activityManager = CMMotionActivityManager()
    
    override init() {
        super.init()
        
        // configure motion manager
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        motionManager.accelerometerUpdateInterval = accUpdateInterval
        motionManager.magnetometerUpdateInterval = magUpdateInterval
        
        // configure location manager
        locationManager.desiredAccuracy = locationAccuracy
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    
    // == STARTING ==
    
    func start() {
        NSLog("Start Motion Manager")
        
        self.startAccelerationLog()
        self.startGyroLog()
        self.startGPSLog()
        self.startMagnetometerLog()
        self.startMotionActivityLog()
    }
    
    func startAccelerationLog() {
        NSLog("Start Acceleration Logging")
        
        if (!motionManager.accelerometerAvailable) {
            NSLog("Accelerometer not available!")
            return
        }
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.logAccelerationData(accelerometerData!)
            
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
            self.logGyroData(gyroData!)
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
            let sensorData = SensorData(timestamp: location.timestamp.timeIntervalSince1970 * 1000, location: location)
            DataLog.sharedInstance.addSensorData(sensorData)
        }
    }
    
    func startMagnetometerLog() {
        NSLog("Start Magnetometer Log")
        
        if (!motionManager.magnetometerAvailable) {
            NSLog("Magnetometer not available!")
            return
        }
        
        motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (magnetometerData: CMMagnetometerData?, NSError) -> Void in
            self.logMagnetometerData(magnetometerData!)
            if (NSError != nil) {
                print("\(NSError)")
            }
        }
    }
    
    func startMotionActivityLog() {
        NSLog("Start Motion Activity Log")
        
        if (!CMMotionActivityManager.isActivityAvailable()) {
            NSLog("Activity Manager not available!")
            return
        }
        
        activityManager.startActivityUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (activityData: CMMotionActivity?) -> Void in
            self.logMotionActivity(activityData!)
        }
    }
    
    
    // == LOGGING ==
    
    func logAccelerationData(data: CMAccelerometerData) {
        let sensorData = SensorData(timestamp: data.timestamp * 1000, acceleration: data.acceleration)
        DataLog.sharedInstance.addSensorData(sensorData)
    }
    
    func logGyroData(data: CMGyroData) {
        let sensorData = SensorData(timestamp: data.timestamp * 1000, rotationRate: data.rotationRate)
        DataLog.sharedInstance.addSensorData(sensorData)
    }
    
    func logMagnetometerData(data: CMMagnetometerData) {
        let sensorData = SensorData(timestamp: data.timestamp, magneticField: data.magneticField)
        DataLog.sharedInstance.addSensorData(sensorData)
    }
    
    func logMotionActivity(data: CMMotionActivity) {
        let sensorData = SensorData(timestamp: data.timestamp, motionActivity: data)
        DataLog.sharedInstance.addSensorData(sensorData)
    }
    
    
    // == STOPPING ==
    
    func stopAccelerationLog() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func stopGyroLog() {
        motionManager.stopGyroUpdates()
    }
    
    func stopGPSLog() {
        locationManager.stopUpdatingLocation()
    }
    
    func stopMagnetometerLog() {
        motionManager.stopMagnetometerUpdates()
    }
    
    func stopMotionActivityLog() {
        activityManager.stopActivityUpdates()
    }
    
    func stop() {
        self.stopAccelerationLog()
        self.stopGyroLog()
        self.stopGPSLog()
        self.stopMagnetometerLog()
        self.stopMotionActivityLog()
    }
}