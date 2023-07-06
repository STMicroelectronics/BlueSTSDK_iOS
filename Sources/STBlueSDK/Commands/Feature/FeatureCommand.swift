//
//  FeatureCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FeatureCommand {
    let type: FeatureCommandType
    let payload: Data?

    public init(type: FeatureCommandType, data: Data?) {
        self.type = type
        self.payload = data
    }
}

extension FeatureCommand: CustomStringConvertible {
    public var description: String {
        "Command type: \(type) - Data: \(payload?.hex ?? "n/a")"
    }
}

public extension FeatureCommand {
    func message(with mask: FeatureMask?, nodeId: UInt8) -> Data {

        let commandData = type.data(with: nodeId)
        let count = payload?.count ?? 0

        let size = mask != nil && type.useMask ? MemoryLayout<FeatureMask>.size + commandData.count + count : commandData.count + count
        var calcData = Data(capacity: size)

        if let mask = mask, type.useMask {
            withUnsafeBytes(of: mask.bigEndian) { calcData.append(contentsOf: $0) }
        }
        
        calcData.append(commandData)
        
        guard let payload = self.payload else { return calcData }

        calcData.append(payload)

        return calcData
    }
}
