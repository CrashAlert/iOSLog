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
    static let locationAccuracy = kCLLocationAccuracyBest
    static let accUpdateInterval = 0.1
    
    // == INSTANCE VARIABLES ==
    
    // Logger Instance
    let dataLog: DataLog
    let withCrashAlerter: Bool
    
    // Motion Activity Manager
    let activityManager = CMMotionActivityManager()
    
    // Motion Manager
    let motionManager: CMMotionManager! = {
        let manager = CMMotionManager()
        manager.accelerometerUpdateInterval = MotionLogger.accUpdateInterval
        return manager
    }()
    
    // Location Manager
    let locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = MotionLogger.locationAccuracy
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    init(sessionName: String, withCrashAlerter: Bool = false) {
        self.dataLog = DataLog(sessionName: sessionName)
        self.withCrashAlerter = withCrashAlerter
        super.init()
        
        // TODO: let user actively authorize on separate view
        // authorize
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
        
        // start crash alerter service
        if withCrashAlerter {
            self.startCrashAlerter()
        }
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
    
    func startCrashAlerter() {
        NSLog("Start Crash Alerter")
        
        CrashAlerterService.sharedInstance.activate()
    }
    
    
    // == LOGGING ==
    
    func logAccelerationData(data: CMAccelerometerData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setAcceleration(data.acceleration)
        dataLog.addSensorData(sensorData)
        
        if withCrashAlerter {
            let x2 = data.acceleration.x * data.acceleration.x
            let y2 = data.acceleration.y * data.acceleration.y
            let z2 = data.acceleration.z * data.acceleration.z
            let accLength = sqrt(x2 + y2 + z2)
            CrashAlerterService.sharedInstance.updateAccelerationIfNeeded(accLength)
        }
    }
    
    func logGyroData(data: CMGyroData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setGyroscope(data.rotationRate)
        dataLog.addSensorData(sensorData)
    }
    
    func logMagnetometerData(data: CMMagnetometerData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setMagneticField(data.magneticField)
        dataLog.addSensorData(sensorData)
    }
    
    func logMotionActivity(data: CMMotionActivity) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setMotionActivity(data)
        dataLog.addSensorData(sensorData)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let sensorData = SensorData()
            sensorData.setGPS(location)
            dataLog.addSensorData(sensorData)
            
            if withCrashAlerter {
                CrashAlerterService.sharedInstance.updateSpeedIfNeeded(location.speed)
            }
        }
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
        
        if withCrashAlerter {
            CrashAlerterService.sharedInstance.deactivate()
        }
    }
}