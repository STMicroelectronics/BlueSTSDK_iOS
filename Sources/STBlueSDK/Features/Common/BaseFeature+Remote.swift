//
//  BaseFeature+Remote.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension BaseFeature {
    
    typealias RemoteFeatureExtractData = (remoteId: UInt16, offset: Int, timestamp: UInt64)
    
    func remoteExtractData(with timestamp: UInt64, data: Data, offset: Int, nodeUnwrapper: inout [UInt16: UnwrapTimeStamp]) -> RemoteFeatureExtractData? {
        
        if data.count - offset < 3 { //2 bytes for the ts + 1 for some data
            return nil
        }
        
        //remove multiple of 2^16 since the node can unwrap the timestamp
        let remoteId = UInt16(timestamp % (1 << 16))

        let extractedTimestamp = data.extractUInt16(fromOffset: offset)
        
        if nodeUnwrapper[remoteId] == nil {
            nodeUnwrapper[remoteId] = UnwrapTimeStamp()
        }
        
        guard let unwrapTimestamp = nodeUnwrapper[remoteId] else {
            return nil
        }
        
        let timestamp = unwrapTimestamp.unwrap(ts: extractedTimestamp)
        
        return (remoteId, offset + 2, timestamp)
    }
    
}
