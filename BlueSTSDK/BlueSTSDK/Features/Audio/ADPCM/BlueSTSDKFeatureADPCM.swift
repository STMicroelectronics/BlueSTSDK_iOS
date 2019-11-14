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

private class ADPCEngine {

    private static let StepSizeTable:[Int16]=[7,8,9,10,11,12,13,14,16,17,
    19,21,23,25,28,31,34,37,41,45,
    50,55,60,66,73,80,88,97,107,118,
    130,143,157,173,190,209,230,253,279,307,
    337,371,408,449,494,544,598,658,724,796,
    876,963,1060,1166,1282,1411,1552,1707,1878,2066,
    2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,
    5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,
    15289,16818,18500,20350,22385,24623,27086,29794,32767]
    
    private static let IndexTable:[Int8] = [-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8];

    private var index:Int16 = 0
    private var predSample:Int32 = 0
    
    func decode(code:Int8, syncManager:BlueSTSDKADPCMManager) -> Int16{
        var step:Int16;
        var diffq:Int32;

        if(syncManager.intra_flag) {
            predSample = syncManager.adpcm_predsample_in;
            index = syncManager.adpcm_index_in;
            syncManager.reinit()
        }
        step = Self.StepSizeTable[Int(index)];

        /* 2. inverse code into diff */
        diffq = Int32(step >> 3);
        if ((code&4) != 0)
        {
            diffq += Int32(step);
        }

        if ((code&2) != 0)
        {
            diffq += Int32(step>>1);
        }

        if ((code&1) != 0)
        {
            diffq += Int32(step>>2);
        }

        /* 3. add diff to predicted sample*/
        if ((code&8) != 0)
        {
            predSample -= diffq;
        }
        else
        {
            predSample += diffq;
        }

        /* check for overflow*/
        if (predSample > 32767)
        {
            predSample = 32767;
        }
        else if (predSample < -32768)
        {
            predSample = -32768;
        }

        /* 4. find new quantizer step size */
        index += Int16(Self.IndexTable [Int(code)])
        /* check for overflow*/
        if (index < 0)
        {
            index = 0;
        }
        if (index > 88)
        {
            index = 88;
        }

        /* 5. save predict sample and index for next iteration */
        /* done! static variables */

        /* 6. return new speech sample*/
        return Int16(predSample);
    }
    
}

public class BlueSTSDKFeatureAudioADPCM : BlueSTSDKFeatureGenericAudio, BlueSTSDKAudioDecoder{
    public var codecManager: BlueSTSDKAudioCodecManager {
        return mCodecStatus
    }
    
    
    public func getAudio(from sample:BlueSTSDKFeatureSample) -> Data? {
        return Self.getLinearPCMAudio(sample)
    }
    
    private static let FEAUTRE_NAME = "Audio"
    private static let FEATURE_FIELDS = [
        BlueSTSDKFeatureField(name: "ADPCM", unit: nil,
                              type: .int16Array,
                              min: NSNumber(value: Int16.min),
                              max: NSNumber(value: Int16.max))
    ]
    private static let FEATURE_DATA_NAME = "ADPCM"
    
    private let mDecoder = ADPCEngine()
    private let mCodecStatus = BlueSTSDKADPCMManager()
    
    override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: Self.FEAUTRE_NAME)
    }
    
    override public func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return Self.FEATURE_FIELDS
    }
 
    override public func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
               
        if((data.count-intOffset) < 20){
           NSException(name: NSExceptionName(rawValue: "Invalid Audio ADPCM data"),
                       reason: "The feature need almost 20 byte for extract the data",
                       userInfo: nil).raise()
           return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
       
        var outArray = Array<NSNumber>()
        for i in intOffset..<(intOffset+20) {
            let temp = mDecoder.decode(code: Int8(data[i]&0x0F), syncManager: mCodecStatus)
            outArray.append(NSNumber(value: temp))
            let temp2 = mDecoder.decode(code: Int8((data[i]>>4) & 0x0F), syncManager: mCodecStatus)
            outArray.append(NSNumber(value:temp2))
        }
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: outArray)
       return BlueSTSDKExtractResult(whitSample: sample, nReadData: 20)
    }
  
    public static func getLinearPCMAudio(_ sample:BlueSTSDKFeatureSample) -> Data?{
        guard sample.data.count == 40 else{
            return nil
        }
        var outData = Data(capacity: 80)
        sample.data.forEach{ value in
            var shortValue = value.int16Value
            let valueBuffer = UnsafeBufferPointer(start: &shortValue, count: 1)
            outData.append(valueBuffer)
        }
        return outData
    }

    override public func description() -> String {
        guard let data = lastSample?.data else {
            return "No Data"
        }
        var s = "Data: "
        data.forEach{ value in
            s = s.appendingFormat("%04X", value.int16Value)
        }
        return s
    }
}
