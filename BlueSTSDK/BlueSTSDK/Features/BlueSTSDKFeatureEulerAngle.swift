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
public class BlueSTSDKFeatureEulerAngle : BlueSTSDKFeatureAutoConfigurable {
    private static let FEATURE_NAME = "Euler Angle";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Yaw", unit: "°", type: .float,
                              min: NSNumber(value: 0), max: NSNumber(value:360.0)),
        BlueSTSDKFeatureField(name: "Pitch", unit: "°", type: .float,
                              min: NSNumber(value: -180.0), max: NSNumber(value:180.0)),
        BlueSTSDKFeatureField(name: "Roll", unit: "°", type: .float,
        min: NSNumber(value: -90.0), max: NSNumber(value:90.0))
    ];
    
    private static let YAW_INDEX = 0;
    private static let PITCH_INDEX = 1;
    private static let ROLL_INDEX = 2;
    
    public static func getYaw( _ sample :BlueSTSDKFeatureSample) -> Float{
        guard sample.data.count > 0 else {
            return Float.nan
        }
        return sample.data[0].floatValue
    }
    
    public static func getPitch( _ sample :BlueSTSDKFeatureSample) -> Float{
        guard sample.data.count > 1 else {
            return Float.nan
        }
        return sample.data[1].floatValue
    }
    
    public static func getRoll( _ sample :BlueSTSDKFeatureSample) -> Float{
        guard sample.data.count > 2 else {
            return Float.nan
        }
        return sample.data[2].floatValue
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureEulerAngle.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureEulerAngle.FEATURE_NAME)
    }
    
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 12){
            NSException(name: NSExceptionName(rawValue: "Invalid Euler Angle data "),
                        reason: "There are no 12 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let uintOffset = UInt(offset)
        let yaw = (data as NSData).extractLeFloat(fromOffset: uintOffset)
        let pitch = (data as NSData).extractLeFloat(fromOffset: uintOffset+4)
        let roll = (data as NSData).extractLeFloat(fromOffset: uintOffset+8)
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [NSNumber(value: yaw),
                                                   NSNumber(value: pitch),
                                                   NSNumber(value: roll)])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 12)
    }
 
}


/*
 
 /**
 * Get the Yaw component
 *
 * @param sample sample data from the sensor
 * @return quaternion Yaw, or Nan if the array doesn't contain data
 */
 public static float getYaw(Sample sample) {
 if(hasValidIndex(sample,YAW_INDEX))
 return sample.data[YAW_INDEX].floatValue();
 //else
 return Float.NaN;
 }
 
 /**
 * Get the Pitch component
 *
 * @param sample sample data from the sensor
 * @return quaternion Pitch, or Nan if the array doesn't contain data
 */
 public static float getPitch(Sample sample) {
 if(hasValidIndex(sample,PITCH_INDEX))
 return sample.data[PITCH_INDEX].floatValue();
 //else
 return Float.NaN;
 }
 
 /**
 * Get the Roll component
 *
 * @param sample sample data from the sensor
 * @return quaternion Roll, or Nan if the array doesn't contain data
 */
 public static float getRoll(Sample sample) {
 if(hasValidIndex(sample,ROLL_INDEX))
 return sample.data[ROLL_INDEX].floatValue();
 //else
 return Float.NaN;
 }
 
 /**
 *
 * @param data       array where read the Field data
 * @param dataOffset offset where start to read the data
 * @return extracted angle and the number or read bytes (12)
 * @throws IllegalArgumentException if the data array has not enough data
 */
 @Override
 protected ExtractResult extractData(long timestamp, byte[] data, int dataOffset) {
 if (data.length - dataOffset < 12)
 throw new IllegalArgumentException("There are no 12 bytes available to read");
 
 float yaw = NumberConversion.LittleEndian.bytesToFloat(data, dataOffset);
 float pitch = NumberConversion.LittleEndian.bytesToFloat(data, dataOffset + 4);
 float roll = NumberConversion.LittleEndian.bytesToFloat(data, dataOffset + 8);
 
 return new ExtractResult(new Sample(timestamp, new Number[]{ yaw,pitch,roll},
 getFieldsDesc()),12);
 }

 */
