//
//  ToFMultiObjectData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ToFMultiObjectData {
    
    let maxObjects = 4
    
    public let objOne: FeatureField<UInt16>
    public let objTwo: FeatureField<UInt16>
    public let objThree: FeatureField<UInt16>
    public let objFour: FeatureField<UInt16>
    
    public let numberOfObjectsFound: FeatureField<UInt8>
    public let numberOfPresencesFound: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
    
        let numberOfObjects = (data.count - offset) / 2
        
        self.numberOfObjectsFound = FeatureField<UInt8>(name: "Num",
                                                        uom: "num",
                                                        min: 0,
                                                        max: UInt8(maxObjects),
                                                        value: UInt8(numberOfObjects))
        
        let numberOfPresencesFound = (((data.count - offset)%2) == 1) ? data.extractUInt8(fromOffset: offset + numberOfObjects * 2) : 0
        
        self.numberOfPresencesFound = FeatureField<UInt8>(name: "Pres",
                                                          uom: "num",
                                                          min: 0,
                                                          max: UInt8.max,
                                                          value: numberOfPresencesFound)
        
        let objOne = numberOfObjects > 0 ? data.extractUInt16(fromOffset: offset) : 0
        let objTwo = numberOfObjects > 1 ? data.extractUInt16(fromOffset: offset) : 0
        let objThree = numberOfObjects > 2 ? data.extractUInt16(fromOffset: offset) : 0
        let objFour = numberOfObjects > 3 ? data.extractUInt16(fromOffset: offset) : 0
        
        self.objOne = FeatureField<UInt16>(name: "Obj",
                                           uom: "mm",
                                           min: 0,
                                           max: 4000,
                                           value: objOne)
        
        self.objTwo = FeatureField<UInt16>(name: "Obj",
                                           uom: "mm",
                                           min: 0,
                                           max: 4000,
                                           value: objTwo)
        
        self.objThree = FeatureField<UInt16>(name: "Obj",
                                           uom: "mm",
                                           min: 0,
                                           max: 4000,
                                           value: objThree)
        
        self.objFour = FeatureField<UInt16>(name: "Obj",
                                           uom: "mm",
                                           min: 0,
                                           max: 4000,
                                           value: objFour)
    }
    
}

extension ToFMultiObjectData: CustomStringConvertible {
    public var description: String {
        let objOne = objOne.value ?? 0
        let objTwo = objTwo.value ?? 0
        let objThree = objThree.value ?? 0
        let objFour = objFour.value ?? 0
        
        let numberOfObjectsFound = numberOfObjectsFound.value ?? 0
        let numberOfPresencesFound = numberOfPresencesFound.value ?? 0
        
        return "Number of objects found: \(numberOfObjectsFound)\n" +
        "Number of presences found: \(numberOfPresencesFound)\n" +
        "Obj One distance: \(objOne)\n" +
        "Obj Two distance: \(objTwo)\n" +
        "Obj Three distance: \(objThree)\n" +
        "Obj Four distance: \(objFour)"
    }
}

extension ToFMultiObjectData: Loggable {
    public var logHeader: String {
        "\(numberOfObjectsFound.logHeader),\(numberOfPresencesFound.logHeader),\(objOne.logHeader),\(objTwo.logHeader),\(objThree.logHeader),\(objFour.logHeader)"
    }
    
    public var logValue: String {
        "\(numberOfObjectsFound.logValue),\(numberOfPresencesFound.logValue),\(objOne.logValue),\(objTwo.logValue),\(objThree.logValue),\(objFour.logValue)"
    }
    
}

public extension ToFMultiObjectData {
    var numberOfPresencesFoundString: String? {
        
        let numberOfPresencesFound = numberOfPresencesFound.value ?? 0
        
        if numberOfPresencesFound == 1 {
            return "1 Person Found"
        } else if numberOfPresencesFound > 1 {
            return "\(numberOfPresencesFound) People Found"
        } else {
            return "No Presence Found"
        }
    }
    
    var numberOfObjectssFoundString: String? {
        
        let numberOfObjectsFound = numberOfObjectsFound.value ?? 0
        
        if numberOfObjectsFound == 1 {
            return "1 Object Found"
        } else if numberOfObjectsFound > 1 {
            return "\(numberOfObjectsFound) Objects Found"
        } else {
            return "No Object Found"
        }
    }
}
