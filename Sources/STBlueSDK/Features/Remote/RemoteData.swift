//
//  RemoteData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct RemoteData<T: Loggable & CustomStringConvertible> {
    let remoteId: UInt16
    let data: T
}

extension RemoteData: CustomStringConvertible {
    public var description: String {
        return "Remote Id: \(remoteId), \(data.description)"
    }
}

extension RemoteData: Loggable {
    public var logHeader: String {
        return "Remote Id, \(data.logHeader)"
    }
    
    public var logValue: String {
        return "\(remoteId), \(data.logValue)"
    }
}
