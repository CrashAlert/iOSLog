//
//  SensorData.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation


class SensorData: CustomStringConvertible {
    let timestamp: NSTimeInterval
    
    let acceleration: CMAcceleration?
    let rotationRate: CMRotationRate?
    let location: CLLocation?
    let magneticField: CMMagneticField?
    let motionActivity: CMMotionActivity?
    // TODO: magnetometer
    // TODO: pressure on iphone 6
    
    var description: String {
        return "SensorData(" + ")"
    }
    
    init(
        timestamp: NSTimeInterval = NSDate().timeIntervalSince1970 * 1000,
        acceleration: CMAcceleration? = nil,
        rotationRate: CMRotationRate? = nil,
        location: CLLocation? = nil,
        magneticField: CMMagneticField? = nil,
        motionActivity: CMMotionActivity? = nil
        )
    {
        self.timestamp = timestamp
        self.acceleration = acceleration
        self.rotationRate = rotationRate
        self.location = location
        self.magneticField = magneticField
        self.motionActivity = motionActivity
    }
    
    func timestampToString() -> String {
        return String(timestamp)
    }
    
    func accelerationToString() -> String {
        if let acc = self.acceleration {
            let strX = String(format: "%.10f", acc.x)
            let strY = String(format: "%.10f", acc.y)
            let strZ = String(format: "%.10f", acc.z)
            
            return "\(strX),\(strY),\(strZ)"
        } else {
            return ",,"
        }
    }
    
    func linearAccelerationToString() -> String {
        // lin
        return ""
    }
    
    func gyroToString() -> String {
        if let gyro = self.rotationRate {
            let strX = String(format: "%.10f", gyro.x)
            let strY = String(format: "%.10f", gyro.y)
            let strZ = String(format: "%.10f", gyro.z)
            
            return "\(strX),\(strY),\(strZ)"
        } else {
            return ",,"
        }
    }
    
    func rotationToString() -> String {
        // x
        // y
        // z
        return ",,"
    }
    
    func magnetometerToString() -> String {
        // x
        // y
        // z
        if let mag = self.magneticField {
            let strX = String(format: "%.10f", mag.x)
            let strY = String(format: "%.10f", mag.y)
            let strZ = String(format: "%.10f", mag.z)
            
            return "\(strX),\(strY),\(strZ)"
        } else {
            return ",,"
        }
    }
    
    func GPSToString() -> String {
        // lat
        // lng
        // course
        // speed
        // altitude
        // error
        if let loc = location {
            let lat = String(loc.coordinate.latitude)
            let lng = String(loc.coordinate.longitude)
            let course = String(loc.course)
            let speed = String(loc.speed)
            let altitude = String(loc.altitude)
            let horizontal = String(loc.horizontalAccuracy)
            let vertical = String(loc.verticalAccuracy)
            
            return [
                lat,
                lng,
                course,
                speed,
                altitude,
                horizontal,
                vertical
            ].joinWithSeparator(",")
        } else {
            return ",,,,,,"
        }
    }
    
    func pressureToString() -> String {
        return ""
    }
    
    func motionActivityToString() -> String {
        if let act = motionActivity {
            let stationary = act.stationary ? "1" : "0"
            let running = act.running ? "1" : "0"
            let walking = act.walking ? "1" : "0"
            let automotive = act.automotive ? "1" : "0"
            let cycling = act.cycling ? "1" : "0"
            let unknown = act.unknown ? "1" : "0"
            
            return [
                stationary,
                running,
                walking,
                automotive,
                cycling,
                unknown
            ].joinWithSeparator(",")
        } else {
            return ",,,,,"
        }
    }
    
    func toString() -> String {
        return [
            self.timestampToString(),
            self.accelerationToString(),
            self.linearAccelerationToString(),
            self.gyroToString(),
            self.rotationToString(),
            self.magnetometerToString(),
            self.GPSToString(),
            self.pressureToString(),
            self.motionActivityToString()
        ].joinWithSeparator(",")
    }
}