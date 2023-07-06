//
//  NEAIClassificationData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct NEAIClassificationData {
    public let mode: FeatureField<NEAIClassModeType>
    public var phase: FeatureField<NEAIClassPhaseType>? = nil
    public var state: FeatureField<NEAIClassStateType>? = nil
    public var classMajorProbability: FeatureField<UInt8>? = nil
    public var classesNumber: FeatureField<UInt8>? = nil
    public var class1Probability: FeatureField<UInt8>? = nil
    public var class2Probability: FeatureField<UInt8>? = nil
    public var class3Probability: FeatureField<UInt8>? = nil
    public var class4Probability: FeatureField<UInt8>? = nil
    public var class5Probability: FeatureField<UInt8>? = nil
    public var class6Probability: FeatureField<UInt8>? = nil
    public var class7Probability: FeatureField<UInt8>? = nil
    public var class8Probability: FeatureField<UInt8>? = nil
    
    
     init(with data: Data, offset: Int) {
         
         let mode = NEAIClassModeType(rawValue: data.extractUInt8(fromOffset: offset + 2))
         
         var phase: NEAIClassPhaseType? = nil
         var state: NEAIClassStateType? = nil
         var classMajorProbability: UInt8? = nil
         var classesNumber: UInt8? = nil
         var class1Probability: UInt8? = nil
         var class2Probability: UInt8? = nil
         var class3Probability: UInt8? = nil
         var class4Probability: UInt8? = nil
         var class5Probability: UInt8? = nil
         var class6Probability: UInt8? = nil
         var class7Probability: UInt8? = nil
         var class8Probability: UInt8? = nil
         
         if data.count - offset == 4 {
             phase = NEAIClassPhaseType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 1))
         } else {
             
             switch mode {
                 
             case .ONE_CLASS:
                 if ((data.count-offset) != 6){
                     NSException(
                        name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "Wrong number of bytes \(data.count-offset) for 1-Class",
                        userInfo: nil
                     ).raise()
                 }
                 
                 phase = NEAIClassPhaseType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 1))
                 state = NEAIClassStateType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 2))
                 classMajorProbability = UInt8(1)
                 classesNumber = UInt8(1)
                 class1Probability = data.extractUInt8(fromOffset: offset + 2 + 3)
                 
             case .N_CLASS:
                 if ((data.count-offset) == 6){
                     phase = NEAIClassPhaseType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 1))
                     state = NEAIClassStateType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 2))
                     classMajorProbability = data.extractUInt8(fromOffset: offset + 2 + 3)
                     if(classMajorProbability != 0) {
                         NSException(
                            name: NSExceptionName(rawValue: "Invalid data"),
                            reason: "Unknown case not valid classMajorProbability != 0",
                            userInfo: nil
                         ).raise()
                     }
                     classesNumber = UInt8(1)
                     
                 } else {
                     let classesNumber = data.count - offset - 6
                     if(classesNumber > 8) {
                         NSException(
                            name: NSExceptionName(rawValue: "Invalid data"),
                            reason: "Too many classes \(classesNumber)",
                            userInfo: nil
                         ).raise()
                     }
                     
                     phase = NEAIClassPhaseType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 1))
                     state = NEAIClassStateType(rawValue: data.extractUInt8(fromOffset: offset + 2 + 2))
                     classMajorProbability = data.extractUInt8(fromOffset: offset + 2 + 3)
                     
                     if(classesNumber == 1) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                     } else if (classesNumber == 2) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                     } else if (classesNumber == 3) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                     } else if (classesNumber == 4) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                         class4Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 3)
                     } else if (classesNumber == 5) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                         class4Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 3)
                         class5Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 4)
                     } else if (classesNumber == 6) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                         class4Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 3)
                         class5Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 4)
                         class6Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 5)
                     } else if (classesNumber == 7) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                         class4Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 3)
                         class5Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 4)
                         class6Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 5)
                         class7Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 6)
                     } else if (classesNumber == 8) {
                         class1Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 0)
                         class2Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 1)
                         class3Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 2)
                         class4Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 3)
                         class5Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 4)
                         class6Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 5)
                         class7Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 6)
                         class8Probability = data.extractUInt8(fromOffset: offset + 2 + 4 + 7)
                     }
                 }
                 
             default:
                 print("Default CASE")
             }
             
         }
         
         self.mode = FeatureField<NEAIClassModeType>(name: "Mode",
                                            uom: nil,
                                            min: .ONE_CLASS,
                                            max: .NULL,
                                            value: mode)
         self.phase = FeatureField<NEAIClassPhaseType>(name: "Phase",
                                                       uom: nil,
                                                       min: .IDLE,
                                                       max: .NULL,
                                                       value: phase)
         self.state = FeatureField<NEAIClassStateType>(name: "State",
                                            uom: nil,
                                            min: .OK,
                                            max: .NULL,
                                            value: state)
         
         self.classMajorProbability = FeatureField<UInt8>(name: "Class Major Prob",
                                            uom: nil,
                                            min: 0,
                                            max: 8,
                                            value: classMajorProbability)
         self.classesNumber = FeatureField<UInt8>(name: "ClassesNumber",
                                            uom: nil,
                                            min: 2,
                                            max: 8,
                                            value: classesNumber)
         
         self.class1Probability = FeatureField<UInt8>(name: "Class 1 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class1Probability)
         self.class2Probability = FeatureField<UInt8>(name: "Class 2 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class2Probability)
         self.class3Probability = FeatureField<UInt8>(name: "Class 3 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class3Probability)
         self.class4Probability = FeatureField<UInt8>(name: "Class 4 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class4Probability)
         self.class5Probability = FeatureField<UInt8>(name: "Class 5 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class5Probability)
         self.class6Probability = FeatureField<UInt8>(name: "Class 6 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class6Probability)
         self.class7Probability = FeatureField<UInt8>(name: "Class 7 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class7Probability)
         self.class8Probability = FeatureField<UInt8>(name: "Class 8 Probability",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: class8Probability)
    }
}

extension NEAIClassificationData: CustomStringConvertible {
    public var description: String {
        
        let mode = mode.value
        let phase = phase?.value
        let state = state?.value
        let classMajorProbability = classMajorProbability?.value
        let classesNumber = classesNumber?.value
        let class1Probability = class1Probability?.value
        let class2Probability = class2Probability?.value
        let class3Probability = class3Probability?.value
        let class4Probability = class4Probability?.value
        let class5Probability = class5Probability?.value
        let class6Probability = class6Probability?.value
        let class7Probability = class7Probability?.value
        let class8Probability = class8Probability?.value
        
        return String(format: "Mode: %@, Phase: %@, State: %@, Class Major Probability: %@, Classes Number: %@, Class 1 Probability: %@, Class 2 Probability: %@, Class 3 Probability: %@, Class 4 Probability: %@, Class 5 Probability: %@, Class 6 Probability: %@, Class 7 Probability: %@, Class 8 Probability: %@,", mode?.description ?? "", phase?.description  ?? "", state?.description ?? "", classMajorProbability?.description ?? "", classesNumber?.description ?? "", class1Probability?.description ?? "", class2Probability?.description ?? "", class3Probability?.description ?? "", class4Probability?.description ?? "", class5Probability?.description ?? "", class6Probability?.description ?? "", class7Probability?.description ?? "", class8Probability?.description ?? "")
    }
}

extension NEAIClassificationData: Loggable {
    public var logHeader: String {
        "\(mode.logHeader),\(phase?.logHeader ?? ""),\(state?.logHeader ?? ""),\(classMajorProbability?.logHeader ?? ""),\(classesNumber?.logHeader ?? ""),\(class1Probability?.logHeader ?? ""),\(class2Probability?.logHeader ?? ""),\(class3Probability?.logHeader ?? ""),\(class4Probability?.logHeader ?? ""),\(class5Probability?.logHeader ?? ""),\(class6Probability?.logHeader ?? ""),\(class7Probability?.logHeader ?? ""),\(class8Probability?.logHeader ?? "")"
    }
    
    public var logValue: String {
        "\(mode.logValue),\(phase?.logValue ?? ""),\(state?.logValue ?? ""),\(classMajorProbability?.logValue ?? ""),\(classesNumber?.logValue ?? ""),\(class1Probability?.logValue ?? ""),\(class2Probability?.logValue ?? ""),\(class3Probability?.logValue ?? ""),\(class4Probability?.logValue ?? ""),\(class5Probability?.logValue ?? ""),\(class6Probability?.logValue ?? ""),\(class7Probability?.logValue ?? ""),\(class8Probability?.logValue ?? "")"
    }
    
}
