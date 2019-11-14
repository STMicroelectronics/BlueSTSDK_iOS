/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
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

#ifndef BlueSTSDK_BlueSTSDKFeature_pro_h
#define BlueSTSDK_BlueSTSDKFeature_pro_h

#import "BlueSTSDKFeature.h"


/**
 * class that contains the number of read bytes and the data extracted from the 
 * raw data stream
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKExtractResult : NSObject

    /** number of read bytes */
    @property(readonly) uint32_t nReadBytes;
    /** sample data build from the raw data */
    @property(readonly,retain,nullable) BlueSTSDKFeatureSample *sample;


/**
 *  build a object of type BlueSTSDKExtractResult with the sample and nReadData
 *  data
 *
 *  @param sample    data extracted
 *  @param nReadData number of bytes used
 *
 *  @return new object of type BlueSTSDKExtractResult
 */
+(nonnull instancetype) resutlWithSample:(nullable BlueSTSDKFeatureSample*)sample
                       nReadData:(uint32_t)nReadData;

/**
 *  initialize a object of type BlueSTSDKExtractResult with the sample and nReadData
 *  data
 *
 *  @param sample    data extracted
 *  @param nReadData number of bytes used
 *
 *  @return new object of type BlueSTSDKExtractResult
 */
-(nonnull instancetype) initWhitSample: (nullable BlueSTSDKFeatureSample*)sample
                     nReadData:(uint32_t)nReadData;

@end

/**
 * This interface contains the protected and packages method that can be used
 * inside the sdk
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeature()

//we redefine the property for be read write, when the user see it in read only
@property (readwrite,atomic) BlueSTSDKFeatureSample * _Nullable lastSample;

/**
 *  set of delegate where notify the feature update
 */
@property(readonly,atomic,retain) NSMutableSet<id<BlueSTSDKFeatureDelegate>> * _Nonnull featureDelegates;

/**
 * @protected
 *  initialize a feature
 *  @par protected function
 *  @param node node that export the feature
 *  @param name name of the feature
 *
 *  @return pointer to the feature
 */
-(instancetype _Nonnull ) initWhitNode: (BlueSTSDKNode*_Nonnull)node name:(NSString*_Nonnull)name;

/**
 *  @protected
 * notify to all the registered delegate that the feature has update its data
 
 *  @par protected function
 *  @param sample new sample data that we want notify
 */
-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample*_Nullable)sample;

/**
 * @protected
 *  notify to all the register delegate that a feature has been
 *  updated using some data
 
 *  @par protected function
 *  @param rawData raw data used for extract the new data
 *  @param sample object with the extracted data
 */
-(void) logFeatureUpdate:(NSData*_Nonnull)rawData sample:(BlueSTSDKFeatureSample*_Nullable)sample;

/**
 *  @protected
 * send a command to this feature using the command characteristics
 *
 *  @par protected function
 *  @param commandType id of the command
 *  @param commandData optional data for the command
 *
 *  @return true if the command is correctly send to the node
 */
-(bool) sendCommand:(uint8_t)commandType data:(NSData*_Nullable)commandData;

/**
 * @protected
 *  parse a command response, the default
 *  implementation is an empty method
 *
 *  @par protected abstract function
 *  @param timestamp   response id
 *  @param commandType id of the command that generate the answer
 *  @param data        response data
 */
-(void) parseCommandResponseWithTimestamp:(uint64_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*_Nonnull)data;

/**
 *  @protected
 * write a data into the feature
 *
 *  @par protected function
 *  @param data data to write into the feature
 */
-(void)writeData:(NSData*_Nonnull)data;


/**
 *  @protected
 *  this method have to extract the feature data from the byte data
 *
 *  @note it is an abstract method, you have to overwrite it!
 *
 *  @param timestamp  package id
 *  @param data      raw data received by the node
 *  @param offset    offset where start to read the raw data
 *
 *  @return object that contains the sample extracted and the number of bytes read
 */
-(nonnull BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(nonnull NSData*)data dataOffset:(uint32_t)offset;

/**
 *  @protected
 *  This method is called by the CBPeriferal to notify an update. this method call
 * the abstract method update and notify to the user the data extracted.
 *
 *  @par package function
 *
 *  @note if you overwrite this function you have to call the method logFeatureUpdate
 * and notifyUpdateWithSample for notify the update to the user
 *
 *  @param timestamp  package id
 *  @param data      raw data received by the node
 *  @param offset    offset where start to read the raw data
 *
 *  @return number of read byte
 */
-(uint32_t) update:(uint64_t)timestamp data:(NSData*_Nonnull)data dataOffset:(uint32_t)offset;

@end

#endif
