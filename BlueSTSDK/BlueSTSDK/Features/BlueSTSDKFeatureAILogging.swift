/*******************************************************************************
 * COPYRIGHT(c) 2018 STMicroelectronics
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

@objc
public class BlueSTSDKFeatureAILogging : BlueSTSDKFeature {

    private static let FEATURE_NAME = "AILogging";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "status", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:3)),
        BlueSTSDKFeatureField(name: "loggedFeature", unit: nil, type: .uInt32,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt32.max)),
        BlueSTSDKFeatureField(name: "enviromentalFreq", unit: nil, type: .uInt16,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt32.max)),
        BlueSTSDKFeatureField(name: "innertialFreq", unit: nil, type: .uInt16,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt32.max))
        
    ];
    
    public enum Status : UInt8{
        public typealias RawValue = UInt8
        
        case stoped = 0x00
        case started = 0x01
        case missingSD = 0x02
        case ioError = 0x03
        case upgrede = 0x04
        case unknown = 0xFF
    }
    
    public struct Parameters{
        public let featureMask:UInt32
        public let environmentalFrequencyHz:Float
        public let inertialFrequencyHz:Float
        public let audioVolume:Float
        
        public init(featureMask:UInt32, environmentalFrequencyHz:Float,
                    inertialFrequencyHz:Float, audioVolume:Float){
            self.featureMask = featureMask
            self.environmentalFrequencyHz = environmentalFrequencyHz
            self.inertialFrequencyHz = inertialFrequencyHz
            self.audioVolume = audioVolume
        }
        
    }
   
    
    public static func getLoggingStatus(_ sample: BlueSTSDKFeatureSample) -> Status{
        guard sample.data.count > 0 else{
            return Status.unknown
        }
        let rawValue = sample.data[0].uint8Value
        return Status(rawValue: rawValue) ?? Status.unknown
    }
    
    public static func isLogging( _ sample: BlueSTSDKFeatureSample) -> Bool{
        return getLoggingStatus(sample) == .started
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureAILogging.FIELDS;
    }
 
    public func startLogging(_ param:Parameters ){
        var message = Data()
        var mutableLogMask = param.featureMask // need to put the log into a Data
        message.append(Status.started.rawValue)
        message.append(Data(bytes: &mutableLogMask,
                            count: MemoryLayout.size(ofValue: mutableLogMask)))
        var intEnviromentalFreq = UInt16((param.environmentalFrequencyHz*10.0).rounded())
        message.append(Data(bytes: &intEnviromentalFreq,
                            count: MemoryLayout.size(ofValue: intEnviromentalFreq)))
        var intInertialFreq = UInt16((param.inertialFrequencyHz*10.0).rounded())
        message.append(Data(bytes: &intInertialFreq,
                            count: MemoryLayout.size(ofValue: intInertialFreq)))
        let volume = UInt8(param.audioVolume*32.0)
        message.append(volume)
        write(message)
    }
    
    public func stopLogging(){
        let message = [Status.stoped.rawValue, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00]
        write(Data(message))
    }
    
    public func updateAnnotation(_ label: String){
        if let rawStr = label.data(using: .utf8){
            // 18 = 20 (max ble length) -1 (status byte) -1 (string terminator)
            let finalLenght = min(18,rawStr.count)
            var message = Data(capacity: finalLenght+2)
            message.append(Status.upgrede.rawValue)
            message.append(rawStr)
            message.append(0)// '\0'
            write(message)
        }
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureAILogging.FEATURE_NAME)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        let packageSize = data.count-intOffset
        guard packageSize>=1 else {
            NSException(name: NSExceptionName(rawValue: "Invalid AI Log data "),
                        reason: "There are no bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let status = data[intOffset]
        
        return BlueSTSDKExtractResult(whitSample: BlueSTSDKFeatureSample(timestamp: timestamp, data: [NSNumber(value:status)]), nReadData: 1)
    }
}
