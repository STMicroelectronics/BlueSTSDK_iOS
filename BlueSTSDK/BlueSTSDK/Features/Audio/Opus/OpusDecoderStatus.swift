/*******************************************************************************
* COPYRIGHT(c) 2019 STMicroelectronics
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*   1. Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
*   2. Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
*   3. Neither the name of STMicroelectronics nor the names of its contributors
*      may be used to endorse or promote products derived from this software
*      without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
******************************************************************************/

import Foundation
import opusLib

class OpusDecoderStatus {
    
    private static let BV_OPUS_TP_START_PACKET = UInt8(0x00);
    private static let BV_OPUS_TP_START_END_PACKET = UInt8(0x20);
    private static let BV_OPUS_TP_MIDDLE_PACKET = UInt8(0x40);
    private static let BV_OPUS_TP_END_PACKET = UInt8(0x80);
    
    typealias OpusDecoder = OpaquePointer
    private var mDecoderData:OpusDecoder? = nil
    private var codedBuffer = Data()
    private var decodedPcmData: [opus_int16] = []
    
    private func allocateDecoder(_ settings:BlueSTSDKOpusManager) -> OpusDecoder{
        let fs = opus_int32(settings.samplingFequency)
        let channels = Int32(settings.channels)
        var error = OPUS_OK
        let decoder = opus_decoder_create(fs, channels, &error)
        let pcmFrameSize = (settings.samplingFequency/1000)*Int(settings.frameSize)
        codedBuffer.reserveCapacity(2*pcmFrameSize)
        decodedPcmData = Array(repeating: 0, count: pcmFrameSize)
        return decoder!
    }
    
    
    
    func decode( rawData:Data, codecSettings:BlueSTSDKOpusManager) -> [NSNumber]?{
        if( mDecoderData == nil){
            mDecoderData = allocateDecoder(codecSettings)
        }
        switch rawData[0] {
        case Self.BV_OPUS_TP_START_PACKET:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(rawData[1...])
            return nil
        case Self.BV_OPUS_TP_START_END_PACKET:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(rawData[1...])
            return decodeBuffer()
        case Self.BV_OPUS_TP_MIDDLE_PACKET:
            codedBuffer.append(rawData[1...])
            return nil
        case Self.BV_OPUS_TP_END_PACKET:
            codedBuffer.append(rawData[1...])
            return decodeBuffer()
        default:
            return nil
        }
    }
    
    private func decodeBuffer() -> [NSNumber]?{
        let outPtr = UnsafeMutablePointer(&decodedPcmData)
        return codedBuffer.withUnsafeBytes{ codedData in
            let inPtr = UnsafePointer<UInt8>(codedData.baseAddress!.assumingMemoryBound(to: UInt8.self))
            let nDecodedSamples = opus_decode(mDecoderData!, inPtr, opus_int32(codedData.count), outPtr, Int32(decodedPcmData.count), 0)
            if(nDecodedSamples == decodedPcmData.count){
                codedBuffer.removeAll(keepingCapacity: true)
                return decodedPcmData.map{NSNumber(value: Int16($0))}
            }else {
                return nil
            }
        }
    }
}
