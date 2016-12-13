//
//  Session.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 31/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation
import RealmSwift

/*
 * Session
 * 
 * Discussion:
 *      Stores log data with a unique session id and holds the session name
 */
class Session: Object {
    dynamic var sessionName = "iOS Log Session"
    let id = NSUUID().UUIDString
    let logs = List<SensorData>()
    
    override static func indexedProperties() -> [String] {
        return ["id", "sessionName"]
    }
}