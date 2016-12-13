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
    // reuse the same realm instance per session
    static let realm: Realm = try! Realm()
    
    // ...but create a new session object
    let session: Session
    
    init(sessionName: String) {
        session = Session()
        session.sessionName = sessionName
        
        try! DataLog.realm.write {
            NSLog("Adding new Session to Realm")
            DataLog.realm.add(session)
        }
    }
    
    /*
     * Write SensorData into Buffer File
     */
    func addSensorData(_ sensorData: SensorData) {
        NSLog("Adding new SensorData at \(sensorData.time)")
        
        // Save your object
        try! DataLog.realm.write {
            session.logs.append(sensorData)
        }
    }
    
    static func getSessions() -> Results<Session> {
        return DataLog.realm.objects(Session)
    }
    
    static func clear(_ session: Session) {
        try! DataLog.realm.write {
            DataLog.realm.delete(session)
        }
    }
    
    static func toCSV(_ session: Session) -> Data {
        let header = [ SensorData.header() ]
        let contents = session.logs
            .sorted(byProperty: "time")
            .map({$0.toString()})
        let data = (header + contents).joined(separator: "\n")
        return data.data(using: String.Encoding.utf8)!
    }

}
