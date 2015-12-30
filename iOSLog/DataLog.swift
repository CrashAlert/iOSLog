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
    
    /*
     * Write SensorData into Buffer File
     */
    func addSensorData(sensorData: SensorData) {
        NSLog(sensorData.toString())
    }
    
    func logData() -> NSData {
        let contents = "No,President Name,Wikipedia URL,Took office,Left office,Party,Home State\n1,George Washington,http://en.wikipedia.org/wiki/George_Washington,30/04/1789,4/03/1797,Independent,Virginia\n2,John Adams,http://en.wikipedia.org/wiki/John_Adams,4/03/1797,4/03/1801,Federalist,Massachusetts\n3,Thomas Jefferson,http://en.wikipedia.org/wiki/Thomas_Jefferson,4/03/1801,4/03/1809,Democratic-Republican,Virginia\n4,James Madison,http://en.wikipedia.org/wiki/James_Madison,4/03/1809,4/03/1817,Democratic-Republican,Virginia\n5,James Monroe,http://en.wikipedia.org/wiki/James_Monroe,4/03/1817,4/03/1825,Democratic-Republican,Virginia\n6,John Quincy Adams,http://en.wikipedia.org/wiki/John_Quincy_Adams,4/03/1825,4/03/1829,Democratic-Republican/National Republican,Massachusetts"
        
        return contents.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
