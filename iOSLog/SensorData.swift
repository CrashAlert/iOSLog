//
//  SensorData.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import Foundation
import CoreMotion


class SensorData {
    let timestamp = NSDate()
    
    let acceleration: CMAcceleration?
    let rotationRate: CMRotationRate?
    // TODO: magnetometer
    // TODO: GPS
    // TODO: bearing
    // TODO: alt
    // TODO: GPS error
    
    init(
        acceleration: CMAcceleration? = nil,
        rotationRate: CMRotationRate? = nil
        )
    {
        self.acceleration = acceleration
        self.rotationRate = rotationRate
    }
    
    func timestampToString() -> String {
        return String(timestamp.timeIntervalSince1970 * 1000)
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
    
    func toString() -> String {
        return "\(self.timestampToString()),"
                + "\(self.accelerationToString())"
                + "\(self.gyroToString())"
    }
    
}