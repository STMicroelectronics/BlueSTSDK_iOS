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

public class BlueSTSDKFeatureMotionAlogrithm : BlueSTSDKFeature{
    private static let FEATURE_NAME = "MotionAlogrithm";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Type", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt8.max)),
        BlueSTSDKFeatureField(name: "Result", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt8.max)),
    ];
    
    public enum Algorithm : UInt8, CaseIterable {
        public typealias RawValue = UInt8
        case none = 0x00
        case poseEstimation = 0x01
        case deskTypeDetection = 0x02
        case verticalContext = 0x03
    }
    
    public enum PoseEstimation : UInt8, CaseIterable{
        public typealias RawValue = UInt8
        case unknown = 0x00
        case sitting = 0x01
        case standing = 0x02
        case layingDown = 0x03
    }
    
    public enum VerticalContext: UInt8, CaseIterable{
        public typealias RawValue = UInt8
        case unknown = 0x00
        case floor = 0x01
        case upDown = 0x02
        case stairs = 0x03
        case elevator = 0x04
        case escalator = 0x05
    }
    
    public enum DeskTypeDetection : UInt8, CaseIterable{
        public typealias RawValue = UInt8
        case unknown = 0x00
        case sittingDesk = 0x01
        case standingDesk = 0x02
    }

    public static func getAlgorithmType(_ sample:BlueSTSDKFeatureSample)->Algorithm?{
        guard sample.data.count > 0 else{
            return nil
        }
        return Algorithm(rawValue: sample.data[0].uint8Value)
    }
    
    public static func getVerticalContext(_ sample:BlueSTSDKFeatureSample) -> VerticalContext?{
        guard getAlgorithmType(sample) == .verticalContext &&
            sample.data.count > 1 else{
                return nil
        }
        return VerticalContext(rawValue: sample.data[1].uint8Value)
    }
    
    public static func getPoseEstimation( _ sample:BlueSTSDKFeatureSample) -> PoseEstimation?{
        guard getAlgorithmType(sample) == .poseEstimation &&
            sample.data.count > 1 else{
                return nil
        }
        return PoseEstimation(rawValue: sample.data[1].uint8Value)
    }
    
    public static func getDetectedDeskType( _ sample:BlueSTSDKFeatureSample) -> DeskTypeDetection?{
        guard getAlgorithmType(sample) == .deskTypeDetection &&
            sample.data.count > 1 else{
                return nil
        }
        return DeskTypeDetection(rawValue: sample.data[1].uint8Value)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureMotionAlogrithm.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureMotionAlogrithm.FEATURE_NAME)
    }
    
    public func enableAlgorithm(_ algo:Algorithm){
        write(Data([algo.rawValue]))
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 2){
            NSException(name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "There are no 2 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let algoId = data[intOffset]
        let algoResultId = data[intOffset+1]
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [
                                                NSNumber(value: algoId),
                                                NSNumber(value: algoResultId)])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 2)
    }
    
}
