//
//  JsonMLCFormat.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public struct JsonMLCFormat: Codable {
    let jsonFormat: JsonMLCFormatVersion?
    let application: JsonMLCApplication?
    let date: String?
    let description: String?
    public let sensors: [JsonMLCSensors]
    
    enum CodingKeys: String, CodingKey {
        case jsonFormat = "json_format"
        case application
        case date
        case description
        case sensors
    }
}

struct JsonMLCFormatVersion: Codable {
    let type: String?
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
    }
}

struct JsonMLCApplication: Codable {
    let name: String?
    let version: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case version
    }
}


public struct JsonMLCSensors: Codable {
    public let name: [String]
    public let configuration: [JsonMLCConfiguration]
    public let outputs: [JsonMLCOutputs]
    let fifoEncodings: [JsonMLCFifoEncodings]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case configuration
        case outputs
        case fifoEncodings = "mlc_identifiers"
    }
    
    public var toPnPLOutputString: String? {
        let writeDelayOperations = self.configuration.filter { $0.type == "write" || $0.type == "delay" }
        
        guard !writeDelayOperations.isEmpty else { return nil }
        
        return writeDelayOperations.map { operation in
            if operation.type == "write" {
                let address = operation.address?.replacingOccurrences(of: "0x", with: "") ?? ""
                let data = operation.data?.replacingOccurrences(of: "0x", with: "") ?? ""
                return address + data
            } else {
                if let data = operation.data, let intData = Int(data) {
                    return String(format: "W%03d", intData)
                } else {
                    return ""
                }
            }
        }.joined()
    }
    
    public var toUcfHeaderStringLabels: String? {
           guard let output = self.outputs.first, !output.results.isEmpty else {
               return nil
           }
           
           let formattedResults = output.results.compactMap { result -> String? in
               var hexCodeWithoutPrefix = result.code
               if result.code.hasPrefix("0x") {
                   hexCodeWithoutPrefix = String(result.code.dropFirst(2))
               }
               
               if let decimalValue = Int(hexCodeWithoutPrefix, radix: 16) {
                   return "\(decimalValue)='\(result.label)'"
               } else {
                   return nil
               }
           }
           
           guard !formattedResults.isEmpty else { return nil }
           
           let resultString = formattedResults.joined(separator: ",")
           
           return "<MLC0_SRC>DT1,\(resultString);"
    }

}

public struct JsonMLCConfiguration: Codable {
    let type: String?
    let address: String?
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case address
        case data
    }
}

public struct JsonMLCOutputs: Codable {
    let name: String?
    let core: String?
    public let type: String?
    let len: String?
    let regAddr: String?
    let regName: String?
    let results: [JsonMLCResult]
    
    enum CodingKeys: String, CodingKey {
        case name
        case core
        case type
        case len
        case regAddr = "reg_addr"
        case regName = "reg_name"
        case results
    }
}

struct JsonMLCFifoEncodings: Codable {
    let tag: String?
    let id: String?
    let label: String?
    
    enum CodingKeys: String, CodingKey {
        case tag
        case id
        case label
    }
}
    
struct JsonMLCResult: Codable {
    let code: String
    let label: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case label
    }
}
