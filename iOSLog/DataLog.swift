//
//  DataLog.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 30/12/15.
//  Copyright © 2015 Sven Mischkewitz. All rights reserved.
//

import Foundation
import RealmSwift


class DataLog {
    static let sharedInstance = DataLog()
    let realm = try! Realm()
    
    /*
     * Write SensorData into Buffer File
     */
    func addSensorData(sensorData: SensorData) {
        NSLog("Adding new SensorData at \(sensorData.time)")
        
        // Save your object
        realm.beginWrite()
        realm.add(sensorData)
        try! realm.commitWrite()
    }
    
    func csvData() -> NSData {
        let header = [ SensorData.header() ]
        let array = try! Realm().objects(SensorData).sorted("time")
        let contents = array.map({$0.toString()})
        let data = (header + contents).joinWithSeparator("\n")
        return data.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func rows() -> Int {
        return try! Realm().objects(SensorData).count
    }
    
    func clear() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
