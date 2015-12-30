//
//  DataLog.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import Foundation


class DataLog {
    static let sharedInstance = DataLog()
    var logs = [SensorData]()
    /*
     * Write SensorData into Buffer File
     */
    func addSensorData(sensorData: SensorData) {
        logs.append(sensorData)
//        print(sensorData.toString())
    }
    
    func csvData() -> NSData {
        let header = SensorData.header()
        let contents = logs.map({$0.toString()}).joinWithSeparator("\n")
        let data = header + contents
        return data.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func clear() {
        print("Clearing \(logs.count) elements.")
        logs.removeAll()
    }
}
