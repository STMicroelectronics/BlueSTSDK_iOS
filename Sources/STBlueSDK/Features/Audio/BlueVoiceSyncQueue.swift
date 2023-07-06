//
//  BlueVoiceSyncQueue.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

/// it create a queue of size nil element, when the queue is empty it will return the last pop element
public class BlueVoiceSyncQueue {
    private var data: [Data?] = [Data?]()
    private var prevData: Data?
    
    private let conditionLock = NSCondition()
    
    public func push(newData: Data) {
        conditionLock.lock()
        data.append(newData)
        conditionLock.unlock()
    }
    
    public func pop() -> Data? {
        var returnValue = prevData
        conditionLock.lock()
        
        if data.count != 0 {
            returnValue = data.removeFirst()
            prevData = returnValue
        }
        
        conditionLock.unlock()
        return returnValue
    }
    
}
