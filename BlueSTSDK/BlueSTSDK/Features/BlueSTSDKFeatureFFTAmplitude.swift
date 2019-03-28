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
public class BlueSTSDKFeatureFFTAmplitude : BlueSTSDKDeviceTimestampFeature {
    private static let FEATURE_NAME = "FFT Amplitude";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "ReceiveStatus", unit: "%", type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:100)),
        BlueSTSDKFeatureField(name: "N Sample", unit: nil, type: .uInt16,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt16.max)),
        BlueSTSDKFeatureField(name: "N Components", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt8.max)),
        BlueSTSDKFeatureField(name: "Frequency Step", unit: "Hz", type: .float,
                              min: NSNumber(value: 0), max: NSNumber(value:Float.greatestFiniteMagnitude)),
    ];
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureFFTAmplitude.FEATURE_NAME)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureFFTAmplitude.FIELDS;
    }

    private class FFTSample : BlueSTSDKFeatureSample{
        
        public let nSample:UInt16
        public let nComponents:UInt8
        public let freqStep:Float
        
        public var dataLoadPercentage:UInt8 {
            get{
                return UInt8((rawData.count*100)/rawDataCapacity)
            }
        }
        
        public var isCompleted:Bool {
            get {
                return rawData.count >= rawDataCapacity
            }
        }
        
        private let rawDataCapacity:Int
        private var rawData:Data
        private var nLastData:UInt = 0
        
        override var data: [NSNumber] {
            get{
                return [
                    NSNumber(value:dataLoadPercentage),
                    NSNumber(value:nSample),
                    NSNumber(value:nComponents),
                    NSNumber(value:freqStep)
                ]
            }
        }
        
        init(timestamp: UInt64, nSample:UInt16, nComponents:UInt8, freqStep:Float) {
            self.nSample = nSample
            self.nComponents = nComponents
            self.freqStep = freqStep
            rawDataCapacity = Int(nSample)*Int(nComponents)*4
            rawData = Data(capacity: rawDataCapacity)// components * 4 byte each float
            super.init(whitTimestamp: timestamp, data:[])
        }
 
        public func append(data : Data){
            rawData.append(data)
        }
        
        public func getComponent(_ index:Int)->[Float]?{
            guard index >= 0 && index<nComponents else{
                return nil
            }
            let startIndex = UInt(index*Int(nSample)*4)
            return rawData.extractFloat(startOffset: startIndex, nFloat: UInt(nSample))
        }
        
        
    }//FFTSample
    
    public static func isComplete( _ sample:BlueSTSDKFeatureSample) -> Bool{
        return (sample as? FFTSample)?.isCompleted ?? false
    }

    public static func getDataLoadPercentage( _ sample:BlueSTSDKFeatureSample)->UInt8{
        return (sample as? FFTSample)?.dataLoadPercentage ?? 0
    }
 
    public static func getNSample( _ sample:BlueSTSDKFeatureSample)->UInt{
        return UInt((sample as? FFTSample)?.nSample ?? 0)
    }
    
    public static func getNComponents( _ sample:BlueSTSDKFeatureSample)->UInt{
        return UInt((sample as? FFTSample)?.nComponents ?? 0)
    }
    
    public static func getFrequencySteps( _ sample:BlueSTSDKFeatureSample)->Float{
        return (sample as? FFTSample)?.freqStep ?? Float.nan
    }
    
    public static func getComponent(_ sample:BlueSTSDKFeatureSample, index:Int)->[Float]?{
        return (sample as? FFTSample)?.getComponent(index)
    }
    
    public static func getXComponent(_ sample:BlueSTSDKFeatureSample)->[Float]?{
        return getComponent(sample, index: 0)
    }
    
    public static func getYComponent(_ sample:BlueSTSDKFeatureSample)->[Float]?{
        return getComponent(sample, index: 1)
    }
    
    public static func getZComponent(_ sample:BlueSTSDKFeatureSample)->[Float]?{
        return getComponent(sample, index: 2)
    }
   
    public static func getComponents(_ sample: BlueSTSDKFeatureSample) -> [[Float]]?{
        guard let fftSample = sample as? FFTSample,
            fftSample.isCompleted else{
                return nil
        }
        
        let nComponents = fftSample.nComponents
        
        return (0..<nComponents)
            .compactMap{ index in
                fftSample.getComponent(Int(index))}
    }
    
    private var mPartialSample:FFTSample? = nil
    
    public override func enableNotification() -> Bool {
        mPartialSample=nil
        return super.enableNotification();
    }
    
    public override func disableNotification() -> Bool {
        mPartialSample=nil
        return super.disableNotification()
    }
    
    private func readHeaderData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt)->FFTSample?{
        let intOffset = Int(offset)
        if((data.count-intOffset) < 12){
            NSException(name: NSExceptionName(rawValue: "Invalid Euler Angle data "),
                        reason: "There are no 12 bytes available to read",
                        userInfo: nil).raise()
            return nil
        }
        
        let nsData = data as NSData
        let nSample = nsData.extractLeUInt16(fromOffset: offset)
        let nComponents = nsData.extractUInt8(fromOffset: offset+2)
        let stepFreq = nsData.extractLeFloat(fromOffset: offset+3)
        
        let sample = FFTSample(timestamp: timestamp, nSample: nSample, nComponents: nComponents, freqStep: stepFreq)
        let fftData = data.subdata(in: Int(offset+7)..<data.count)
        sample.append(data:fftData)
        return sample
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        var returnSample:BlueSTSDKFeatureSample?=nil
        if(mPartialSample == nil){
            mPartialSample = readHeaderData(timestamp,data:data,dataOffset: UInt(offset))
            returnSample = mPartialSample
        }else{
            mPartialSample?.append(data: data)
            returnSample = mPartialSample
            if(mPartialSample?.isCompleted ?? false ){
                mPartialSample = nil
            }
        }
        return BlueSTSDKExtractResult(whitSample: returnSample, nReadData: UInt32(data.count))
    }//extractData
}

fileprivate extension Data {
    func extractFloat(startOffset: UInt, nFloat:UInt)->[Float]?{
        //check we have enought data
        guard (UInt(count)-startOffset) >= nFloat*4 else {
            return nil
        }
        
        var floatData = Array<Float>(repeating: 0.0, count: Int(nFloat))
        let nsData = (self as NSData)
        for i in 0..<Int(nFloat) {
            floatData[i] = nsData.extractLeFloat(fromOffset: startOffset+UInt(i)*4)
        }
        
        return floatData
    }//extractFloat
}// Data extension
