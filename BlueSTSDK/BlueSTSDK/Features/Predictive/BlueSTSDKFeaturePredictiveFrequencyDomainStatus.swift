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

public class BlueSTSDKFeaturePredictiveFrequencyDomainStatus : BlueSTSDKFeaturePredictiveStatus{
    
    private static let FEATURE_NAME = "PredictiveFrequencyDomainStatus"
    
    private static func buildAccField(name:String)->BlueSTSDKFeatureField{
        return BlueSTSDKFeatureField(name: name, unit: "m/s^2", type: .float,
                                     min: NSNumber(value:0.0),
                                     max: NSNumber(value:Float(1<<16)/10.0))
    }
    
    private static func buildFreqField(name:String)->BlueSTSDKFeatureField{
        return BlueSTSDKFeatureField(name: name, unit: "Hz", type: .float,
                                     min: NSNumber(value:0.0),
                                     max: NSNumber(value:Float(1<<16)/100.0))
    }
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_X"),
        BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_Y"),
        BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_Z"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildFreqField(name: "Freq_X"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildFreqField(name: "Freq_Y"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildFreqField(name: "Freq_Z"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildAccField(name: "MaxAmplitude_X"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildAccField(name: "MaxAmplitude_Y"),
        BlueSTSDKFeaturePredictiveFrequencyDomainStatus.buildAccField(name: "MaxAmplitude_Z")
    ]
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return  BlueSTSDKFeaturePredictiveFrequencyDomainStatus.FIELDS
    }
    
    public static func getStatusX(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 0)
    }
    
    public static func getStatusY(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 1)
    }
    
    public static func getStatusZ(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 2)
    }
    
    public static func getWorstXFrequency(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 3)
    }
    
    public static func getWorstYFrequency(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 4)
    }
    
    public static func getWorstZFrequency(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 5)
    }
    
    public static func getWorstXValue(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 6)
    }
    
    public static func getWorstYValue(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 7)
    }
    
    public static func getWorstZValue(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 8)
    }
    
    public static func getWorstXPoint(_ sample:BlueSTSDKFeatureSample)->(Float,Float){
        return (getWorstXFrequency(sample),getWorstXValue(sample))
    }
    
    public static func getWorstYPoint(_ sample:BlueSTSDKFeatureSample)->(Float,Float){
        return (getWorstYFrequency(sample),getWorstYValue(sample))
    }
    
    public static func getWorstZPoint(_ sample:BlueSTSDKFeatureSample)->(Float,Float){
        return (getWorstZFrequency(sample),getWorstZValue(sample))
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name:  BlueSTSDKFeaturePredictiveFrequencyDomainStatus.FEATURE_NAME)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 12){
            NSException(name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "There are no 12 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let uintOffset = UInt(offset)
        let status = data[intOffset]
        let freqX = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+1))/10.0
        let valX = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+3))/100.0
        let freqY = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+5))/10.0
        let valY = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+7))/100.0
        let freqZ = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+9))/10.0
        let valZ = Float((data as NSData).extractLeUInt16(fromOffset: uintOffset+11))/100.0
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [
                                                BlueSTSDKFeaturePredictiveStatus.extractXStatus(status).toNumber(),
                                                BlueSTSDKFeaturePredictiveStatus.extractYStatus(status).toNumber(),
                                                BlueSTSDKFeaturePredictiveStatus.extractZStatus(status).toNumber(),
                                                NSNumber(value: freqX),
                                                NSNumber(value: freqY),
                                                NSNumber(value: freqZ),
                                                NSNumber(value: valX),
                                                NSNumber(value: valY),
                                                NSNumber(value: valZ) ])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 12)
    }
}

