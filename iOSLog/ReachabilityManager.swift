//
//  ReachabilityManager.swift
//  iOSLog
//
//  Created by Sven Mischkewitz on 04/01/16.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//


class ReachabilityManager {
    class func hasConnectivity() -> Bool {
        let networkStatus: Reachability.NetworkStatus
        do {
            let reachability: Reachability = try Reachability.reachabilityForLocalWiFi()
            networkStatus = reachability.currentReachabilityStatus
        } catch {
            // no network on error
            networkStatus = Reachability.NetworkStatus.NotReachable
        }
        
        return networkStatus == Reachability.NetworkStatus.ReachableViaWiFi
    }
}