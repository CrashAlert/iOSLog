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

import RealmSwift


class StorableSensorData: Object {
    static let gravity = 9.80665
    
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

    dynamic var time: Double
    
    let acc_x = RealmOptional<Double>()
    let acc_y = RealmOptional<Double>()
    let acc_z = RealmOptional<Double>()
    
    let gyr_x = RealmOptional<Double>()
    let gyr_y = RealmOptional<Double>()
    let gyr_z = RealmOptional<Double>()
    
    let mag_x = RealmOptional<Double>()
    let mag_y = RealmOptional<Double>()
    let mag_z = RealmOptional<Double>()
    
    let lat = RealmOptional<Double>()
    let lng = RealmOptional<Double>()
    let bearing = RealmOptional<Double>()
    let speed = RealmOptional<Double>()
    let alt = RealmOptional<Double>()
    let err_lat = RealmOptional<Double>()
    let err_lng = RealmOptional<Double>()
    
    let pressure = RealmOptional<Double>()
    
    let station = RealmOptional<Bool>()
    let run = RealmOptional<Bool>()
    let walk = RealmOptional<Bool>()
    let auto = RealmOptional<Bool>()
    let cycling = RealmOptional<Bool>()
    let unknown = RealmOptional<Bool>()
    
    required init() {
        time = CACurrentMediaTime() * 1e9
        super.init()
    }
    
    func setAcceleration(acc: CMAcceleration) {
        acc_x.value = acc.x * SensorData.gravity
        acc_y.value = acc.y * SensorData.gravity
        acc_z.value = acc.z * SensorData.gravity
    }
    
    func setGyroscope(gyr: CMRotationRate) {
        gyr_x.value = gyr.x
        gyr_y.value = gyr.y
        gyr_z.value = gyr.z
    }
    
    func setMagneticField(mag: CMMagneticField) {
        mag_x.value = mag.x
        mag_y.value = mag.y
        mag_z.value = mag.z
    }
    
    func setGPS(gps: CLLocation) {
        lat.value = gps.coordinate.latitude
        lng.value = gps.coordinate.longitude
        bearing.value = gps.course
        speed.value = gps.speed
        alt.value = gps.altitude
        err_lat.value = gps.horizontalAccuracy
        err_lng.value = gps.verticalAccuracy
    }
    
    func setMotionActivity(act: CMMotionActivity) {
        station.value = act.stationary
        run.value = act.running
        walk.value = act.walking
        auto.value = act.automotive
        cycling.value = act.cycling
        unknown.value = act.unknown
    }
    
    func timeToString() -> String {
        return String(format: "%.0f", time)
    }
    
    func accelerationToString() -> String {
        if let _ = self.acc_x.value {
            let strX = String(format: "%.10f", acc_x.value! * SensorData.gravity)
            let strY = String(format: "%.10f", acc_y.value! * SensorData.gravity)
            let strZ = String(format: "%.10f", acc_z.value! * SensorData.gravity)
            
            return "\(strX),\(strY),\(strZ)"
        }
        else {
            return ",,"
        }
    }
    
    func linearPlaceholder() -> String {
        // Only written by android
        return ",,"
    }
    
    func gyroToString() -> String {
        if let _ = self.gyr_x.value {
            let strX = String(format: "%.10f", gyr_x.value!)
            let strY = String(format: "%.10f", gyr_y.value!)
            let strZ = String(format: "%.10f", gyr_z.value!)
            
            return "\(strX),\(strY),\(strZ)"
        }
        else {
            return ",,"
        }
    }
    
    func rotationPlaceholder() -> String {
        // Currently only written by android
        return ",,"
    }
    
    func magnetometerToString() -> String {
        if let _ = self.mag_x.value {
            let strX = String(format: "%.10f", mag_x.value!)
            let strY = String(format: "%.10f", mag_y.value!)
            let strZ = String(format: "%.10f", mag_z.value!)
            
            return "\(strX),\(strY),\(strZ)"
        }
        else {
            return ",,"
        }
    }
    
    func GPSToString() -> String {
        if let _ = self.lat.value {
            let lat = String(self.lat)
            let lng = String(self.lng)
            let course = String(self.bearing)
            let speed = String(self.speed)
            let altitude = String(self.alt)
            let horizontal = String(self.err_lat)
            let vertical = String(self.err_lng)
            
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
        // currently only written by android
        return ""
    }
    
    func motionActivityToString() -> String {
        if let _ = self.station.value {
            let stationary = self.station.value! ? "1" : "0"
            let running = self.run.value! ? "1" : "0"
            let walking = self.walk.value! ? "1" : "0"
            let automotive = self.auto.value! ? "1" : "0"
            let cycling = self.cycling.value! ? "1" : "0"
            let unknown = self.unknown.value! ? "1" : "0"
            
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
            self.timeToString(),
            self.accelerationToString(),
            self.linearPlaceholder(),
            self.gyroToString(),
            self.rotationPlaceholder(),
            self.magnetometerToString(),
            self.GPSToString(),
            self.pressureToString(),
            self.motionActivityToString()
            ].joinWithSeparator(",")
    }
}


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
        NSLog(String(format: "%.0f", self.timestamp))
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