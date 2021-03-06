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
    // == INSTANCE VARIABLES ==
    
    // Logger Instance
    let dataLog: DataLog
    
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
    
    init(sessionName: String) {
        dataLog = DataLog(sessionName: sessionName)
        super.init()
        
        // configure motion manager
        motionManager.gyroUpdateInterval = gyroUpdateInterval
        motionManager.accelerometerUpdateInterval = accUpdateInterval
        motionManager.magnetometerUpdateInterval = magUpdateInterval
        
        // configure location manager
        locationManager.desiredAccuracy = locationAccuracy
        locationManager.delegate = self
        
        // TODO: let user actively authorize on separate view
        // authorize
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
        
        if (!motionManager.isAccelerometerAvailable) {
            NSLog("Accelerometer not available!")
            return
        }
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.logAccelerationData(accelerometerData!)
            
            if (NSError != nil) {
                print("\(NSError)")
            }
        }
    }
    
    func startGyroLog() {
        NSLog("Start Gyro Logging")
        
        if (!motionManager.isGyroAvailable) {
            NSLog("Gyro not available!")
            return
        }
        
        motionManager.startGyroUpdates(to: OperationQueue.current!) {
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
        
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            // this only happens when location services were not enabled in startGPSLog before
            self.startGPSLog()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let sensorData = SensorData()
            sensorData.setGPS(location)
            dataLog.addSensorData(sensorData)
        }
    }
    
    func startMagnetometerLog() {
        NSLog("Start Magnetometer Log")
        
        if (!motionManager.isMagnetometerAvailable) {
            NSLog("Magnetometer not available!")
            return
        }
        
        motionManager.startMagnetometerUpdates(to: OperationQueue.current!) {
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
        
        activityManager.startActivityUpdates(to: OperationQueue.current!) {
            (activityData: CMMotionActivity?) -> Void in
            self.logMotionActivity(activityData!)
        }
    }
    
    
    // == LOGGING ==
    
    func logAccelerationData(_ data: CMAccelerometerData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setAcceleration(data.acceleration)
        dataLog.addSensorData(sensorData)
    }
    
    func logGyroData(_ data: CMGyroData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setGyroscope(data.rotationRate)
        dataLog.addSensorData(sensorData)
    }
    
    func logMagnetometerData(_ data: CMMagnetometerData) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setMagneticField(data.magneticField)
        dataLog.addSensorData(sensorData)
    }
    
    func logMotionActivity(_ data: CMMotionActivity) {
        let sensorData = SensorData()
        sensorData.time = data.timestamp * 1e9
        sensorData.setMotionActivity(data)
        dataLog.addSensorData(sensorData)
    }
    
    
    // == STOPPING ==
    
    func stopAccelerationLog() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func stopGyroLog() {
        motionManager.stopGyroUpdates()
    }
    
    func stopGPSLog() {
        NSLog("Stop GPS")
        
        locationManager.stopUpdatingLocation()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = false
        }
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
