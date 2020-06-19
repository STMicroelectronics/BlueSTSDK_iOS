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

public class BlueSTSDKFeatureFiniteStateMachine : BlueSTSDKFeature{
    private static let N_REGISTER_NUMBER = 16
    private static let FEATURE_NAME = "Finite State Machine";
    private static let FIELDS:[BlueSTSDKFeatureField] =  (0..<N_REGISTER_NUMBER).map{ i in
        BlueSTSDKFeatureField(name: "Register_\(i)", unit: nil, type: .uInt8,
        min: NSNumber(value: 0), max: NSNumber(value:UInt8.max))
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureFiniteStateMachine.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureFiniteStateMachine.FEATURE_NAME)
    }
    
    public static func getRegisterStatus( _ sample:BlueSTSDKFeatureSample) -> [UInt8] {
        return sample.data.map{ $0.uint8Value }
    }
    
    public static func getRegisterStatus( _ sample:BlueSTSDKFeatureSample, index:Int) -> UInt8?{
        guard sample.data.count > index else{
            return nil
        }
        return sample.data[index].uint8Value
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < Self.N_REGISTER_NUMBER){
            NSException(name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "There are no \(Self.N_REGISTER_NUMBER) bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let status = (intOffset..<(intOffset+Self.N_REGISTER_NUMBER)).map{
            NSNumber(value: data[$0])
        }
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: status)
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: UInt32(Self.N_REGISTER_NUMBER))
    }
    
}
