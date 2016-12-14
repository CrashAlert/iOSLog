//
//  S3Exporter.swift
//  iOSLog
//
//  Created by Nico Ring on 14/12/2016.
//  Copyright © 2016 Sven Mischkewitz. All rights reserved.
//

import Foundation
import AWSS3

class S3Exporter {
    static let sharedInstance = S3Exporter()
    
    let s3BucketName = "crashalerter-test"
    
    let cognitoPoolId = "us-east-1:bff3f3c7-cffe-4db7-b3ad-a515125fa4d3"
    let region = AWSRegionType.usEast1
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: region,
            identityPoolId: cognitoPoolId
        )
        
        let configuration = AWSServiceConfiguration(
            region: region,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func export() -> Bool {
        let sessions = DataLog.getSessions()
        sessions.forEach(upload)
        return false
    }
    
    func upload(session: Session) {
        let transferUtility = AWSS3TransferUtility.default()
        let name = session.sessionName
        let data = DataLog.toCSV(session)
        
        let awstask = transferUtility.uploadData(data, bucket: s3BucketName, key: name, contentType: "text/csv", expression: nil, completionHander: nil)
        
        awstask.continue({ (task) -> AnyObject! in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            if let exception = task.exception {
                print("Exception: \(exception.description)")
            }
            if let result = task.result {
                print("Upload Starting: \(result.description)")
            }
            
            return nil;
        })
    }
}
