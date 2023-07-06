//
//  OpusEngine.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import YbridOpus

class OpusEngine {
    
    enum OpusPacket: UInt8 {
        case start = 0x00
        case startEnd = 0x20
        case middle = 0x40
        case end = 0x80
    }
    
    typealias OpusDecoder = OpaquePointer
    
    private var decoder: OpusDecoder? = nil
    private var codedBuffer = Data()
    private var decodedPcmData: [opus_int16] = []
    
    private func allocateDecoder(_ settings: OpusCodecManager) -> OpusDecoder? {
        let fs = opus_int32(settings.samplingFequency)
        let channels = Int32(settings.channels)
        var error = OPUS_OK
        let decoder = opus_decoder_create(fs, channels, &error)
        let pcmFrameSize = (settings.samplingFequency / 1000) * Int(settings.frameSize)
        codedBuffer.reserveCapacity(2 * pcmFrameSize)
        decodedPcmData = Array(repeating: 0, count: pcmFrameSize)
        return decoder
    }
    
    func decode(data: Data, audioManager: OpusCodecManager) -> [Int16]? {
        if decoder == nil {
            decoder = allocateDecoder(audioManager)
        }
        
        switch data[0] {
        case OpusPacket.start.rawValue:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
        case OpusPacket.startEnd.rawValue:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
            return decodeBuffer()
        case OpusPacket.middle.rawValue:
            codedBuffer.append(data[1...])
        case OpusPacket.end.rawValue:
            codedBuffer.append(data[1...])
            return decodeBuffer()
        default:
            break
        }
        
        return nil
    }
    
    private func decodeBuffer() -> [Int16]? {
        guard let decoder = decoder else { return nil }
        
        let outPtr = UnsafeMutablePointer(&decodedPcmData)
        return codedBuffer.withUnsafeBytes{ codedData in
            let inPtr = UnsafePointer<UInt8>(codedData.baseAddress!.assumingMemoryBound(to: UInt8.self))
            let nDecodedSamples = opus_decode(decoder,
                                              inPtr,
                                              opus_int32(codedData.count),
                                              outPtr,
                                              Int32(decodedPcmData.count),
                                              0)
            if nDecodedSamples == decodedPcmData.count {
                codedBuffer.removeAll(keepingCapacity: true)
                return decodedPcmData.map { Int16($0) }
            } else {
                return nil
            }
        }
    }
}
