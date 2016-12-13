//
//  ReachabilityManager.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 04/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//
import ReachabilitySwift

class ReachabilityManager {
    static let reachability = Reachability()!
    
    class func hasConnectivity() -> Bool {
        return reachability.isReachableViaWiFi
    }
}
