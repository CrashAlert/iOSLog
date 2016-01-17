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
import QuartzCore


class SensorData: CustomStringConvertible {
    static func header() -> String {
        return [
            "time",
            "acc_x",
            "acc_y",
            "acc_z",
            "lin_acc_x",
            "lin_acc_y",
            "lin_acc_z",
            "gyr_x",
            "gyr_y",
            "gyr_z",
            "rot_x",
            "rot_y",
            "rot_z",
            "mag_x",
            "mag_y",
            "mag_z",
            "lat",
            "lng",
            "bearing",
            "speed",
            "alt",
            "err_lat",
            "err_lng",
            "pressure",
            "station",
            "run",
            "walk",
            "auto",
            "cycling",
            "unknown"
        ].joinWithSeparator(",") + ","
    }
    
    
    let timestamp: Double
    
    let acceleration: CMAcceleration?
    static let gravity = 9.80665
    let rotationRate: CMRotationRate?
    let location: CLLocation?
    let magneticField: CMMagneticField?
    let motionActivity: CMMotionActivity?
    // TODO: pressure on iphone 6
    
    var description: String {
        return "SensorData(" /* TODO: implement printable info */ + ")"
    }
    
    init(
        timestamp: Double = CACurrentMediaTime() * 1e9,
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
//        NSLog(String(format: "%.0f", self.timestamp))
    }
    
    func timestampToString() -> String {
        return String(format: "%.0f", timestamp)
    }
    
    func accelerationToString() -> String {
        if let acc = self.acceleration {
            let strX = String(format: "%.10f", acc.x * SensorData.gravity)
            let strY = String(format: "%.10f", acc.y * SensorData.gravity)
            let strZ = String(format: "%.10f", acc.z * SensorData.gravity)
            
            return "\(strX),\(strY),\(strZ)"
        } else {
            return ",,"
        }
    }
    
    func linearAccelerationToString() -> String {
        // lin
        return ",,"
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