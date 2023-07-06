//
//  DataTransporter.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct DataTransporterConfig {
    var mtu: Int
    var startPacket: UInt8
    var startEndPacket: UInt8
    var middlePacket: UInt8
    var endPacket: UInt8

    public init(mtu: Int,
                startPacket: UInt8,
                startEndPacket: UInt8,
                middlePacket: UInt8,
                endPacket: UInt8) {
        self.mtu = mtu
        self.startPacket = startPacket
        self.startEndPacket = startEndPacket
        self.middlePacket = middlePacket
        self.endPacket = endPacket
    }

    static var standard: DataTransporterConfig = DataTransporterConfig(mtu: 20,
                                                                       startPacket: 0x00,
                                                                       startEndPacket: 0x20,
                                                                       middlePacket: 0x40,
                                                                       endPacket: 0x80)
}

public class DataTransporter {
    private var codedBuffer = Data()
    private let debug = true

    public var config: DataTransporterConfig = DataTransporterConfig.standard
    
    public func decapsulate(data: Data) -> Data? {
        
        switch data[0] {
        case config.startPacket:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
            return nil
            
        case config.startEndPacket:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
            return codedBuffer
            
        case config.middlePacket:
            codedBuffer.append(data[1...])
            return nil
            
        case config.endPacket:
            codedBuffer.append(data[1...])
            return codedBuffer
            
        default:
            return nil
        }
    }
    
    public func encapsulate(string: String?) -> Data {
        guard let byteCommand = string?.data(using: .utf8) else { return Data() }
        
        var head = config.startPacket
        var data = Data()
        let mtuSize = config.mtu
        var count = 0
        let codedDataLength = byteCommand.count
        let codedDataLengthBytes = Data(bytes: Int16(codedDataLength).reversedBytes, count: Int16(codedDataLength).reversedBytes.count)
        
        while count < codedDataLength {
            var size = min(Int(mtuSize) - 1, codedDataLength - count)
            if codedDataLength - count <= mtuSize - 1 {
                if count == 0 {
                    if codedDataLength - count <= mtuSize - 3 {
                        head = config.startEndPacket
                    } else {
                        head = config.startPacket
                    }
                } else {
                    head = config.endPacket
                }
            }
            
            switch head {
            case config.startPacket:
                let to = (mtuSize - 3) - 1
                data.append(head)
                data.append(codedDataLengthBytes)
                data.append(byteCommand[0...to])
                size = Int(mtuSize - 3)
                head = config.middlePacket
                
                if debug {
                    STBlueSDK.log(text: "set data from 0 to \(to), size: \(size) -> \(byteCommand[0...to])")
                }
                
            case config.startEndPacket:
                data.append(head)
                data.append(codedDataLengthBytes)
                data.append(byteCommand[0...(codedDataLength - 1)])
                size = codedDataLength
                head = config.startPacket
                
                if debug {
                    STBlueSDK.log(text: "set data from 0 to \(codedDataLength), size: \(size) -> \(byteCommand[0..<codedDataLength])")
                }
                
            case config.middlePacket:
                let to = (count + (mtuSize - 1)) - 1
                
                data.append(head)
                data.append(byteCommand[count...to])
                
                if debug {
                    STBlueSDK.log(text: "set data from \(count) to \( to ), size: \(size) -> \(byteCommand[count...to])")
                }
                
            case config.endPacket:
                data.append(head)
                data.append(byteCommand[count...])
                head = config.startPacket
                
                if debug {
                    STBlueSDK.log(text: "set data from \(count) to END, size: \(size) -> \(byteCommand[count...])")
                }
                
            default:
                break
            }
            
            count += size
        }
        
        if debug {
            STBlueSDK.log(text: "result: \(String(data: data, encoding: .ascii) ?? "n/a")")
            STBlueSDK.log(text: "Result hex: \(data.hex)")
        }
        
        return data
    }

    public func clear() {
        codedBuffer = Data()
    }
}
