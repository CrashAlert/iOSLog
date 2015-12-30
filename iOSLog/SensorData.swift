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
    
    let acceleration: CMAcceleration
    let rotationRate: CMRotationRate
    // TODO: magnetometer
    // TODO: GPS
    // TODO: bearing
    // TODO: alt
    // TODO: GPS error
    
    init(
        acceleration: CMAcceleration,
        rotationRate: CMRotationRate
        )
    {
        self.acceleration = acceleration
        self.rotationRate = rotationRate
    }
    
    func timestampToString() -> String {
        return String(timestamp.timeIntervalSince1970 * 1000)
    }
    
    func toString() -> String {
        return "\(self.timestampToString())"
    }
    
}