//
//  S3Exporter.swift
//  iOSLog
//
//  Created by Nico Ring on 14/12/2016.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation
import AWSS3
import PromiseKit

class S3Exporter {
    static let sharedInstance = S3Exporter()
    
    let s3BucketName = "crashalerter-test"
    
    let cognitoPoolId = "us-east-1:bff3f3c7-cffe-4db7-b3ad-a515125fa4d3"
    let cognitoRegion = AWSRegionType.usEast1
    let s3Region = AWSRegionType.euCentral1
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: cognitoRegion,
            identityPoolId: cognitoPoolId
        )
        
        let configuration = AWSServiceConfiguration(
            region: s3Region,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func export() -> Promise<Void> {
        let sessions = DataLog.getSessions()
        let promises: [Promise<Void>] = sessions.map(upload)
        return when(fulfilled: promises)
    }
    
    func getFileName(sessionName: String) -> String {
        let date = Date()
        let formatterForName = DateFormatter()
        formatterForName.dateFormat = "yyyyMMddHHmmss"
        let dateName = formatterForName.string(from: date)
        let deviceName = UIDevice.current.name
        return "\(dateName)-\(sessionName)-iOS-\(deviceName).csv"
    }
    
    func upload(session: Session) -> Promise<Void> {
        return Promise { fulfill, reject in
            let transferUtility = AWSS3TransferUtility.default()
            let name = session.sessionName
            let data = DataLog.toCSV(session)
            let key = getFileName(sessionName: name)
        
            let awstask = transferUtility.uploadData(data, bucket: s3BucketName, key: key, contentType: "text/csv", expression: nil, completionHander: nil)
        
            awstask.continue({ (task) -> AnyObject! in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }
                
                if let exception = task.exception {
                    print("Exception: \(exception.description)")
                }
                
                if task.isCompleted {
                    print("Upload Completed")
//                    DataLog.clear(session)
                }

                if task.isCancelled {
                    print("Upload Cancelled")
                }

                if task.isFaulted {
                    print("Upload Faulted")
                }
                fulfill()

                return nil;
            })
        }
    }
}
