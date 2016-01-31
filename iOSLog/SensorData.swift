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


class SensorData: Object {
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

    dynamic var time: Double = CACurrentMediaTime() * 1e9
    
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
    
    func setNanoTime(t: Double) {
        time = t
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
    
    static func TripleToString(x: Double, y: Double, z: Double) -> String {
        let strX = String(format: "%.10f", x)
        let strY = String(format: "%.10f", y)
        let strZ = String(format: "%.10f", z)
        return "\(strX),\(strY),\(strZ)"
    }
    
    func accelerationToString() -> String {
        if let _ = self.acc_x.value {
            return SensorData.TripleToString(
                acc_x.value!, y: acc_y.value!, z: acc_z.value!)
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
            return SensorData.TripleToString(
                gyr_x.value!, y: gyr_y.value!, z: gyr_z.value!)
        }
        else {
            return ",,"
        }
    }
    
    func rotationPlaceholder() -> String {
        // currently only written by android
        return ",,"
    }
    
    func magnetometerToString() -> String {
        if let _ = mag_x.value {
            return SensorData.TripleToString(
                mag_x.value!, y: mag_y.value!, z: mag_z.value!)
        }
        else {
            return ",,"
        }
    }
    
    func GPSToString() -> String {
        if let _ = self.lat.value {
            let lat = String(self.lat.value!)
            let lng = String(self.lng.value!)
            let course = String(self.bearing.value!)
            let speed = String(self.speed.value!)
            let altitude = String(self.alt.value!)
            let horizontal = String(self.err_lat.value!)
            let vertical = String(self.err_lng.value!)
            
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
