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

#ifndef BlueSTSDK_BlueSTSDKFeatureBattery_h
#define BlueSTSDK_BlueSTSDKFeatureBattery_h


#import "BlueSTSDKFeature.h"

@protocol BlueSTSDKFeatureBatteryDelegate;


/**
 * this feature export the from the battery information from expansion board
 * \par
 * The data exported are an array of 3 float component (% of charge,voltage,current)
 * and the buttery status as an enum value
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureBattery : BlueSTSDKFeature

/**
 * Enumeration that contains the battery status
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureBatteryStatus){
    /**
     *  The battery has a level below the 10%
     */
    BlueSTSDKFeatureBatteryStatusLowBattery  =0x00,
    /**
     *  The battery is discharging
     */
    BlueSTSDKFeatureBatteryStatusDischarging =0x01,
    /**
     *  The battery is plugged, but is already charged
     */
    BlueSTSDKFeatureBatteryStatusPluggedNotCharging =0x02,
    /**
     *  the battery is charging
     */
    BlueSTSDKFeatureBatteryStatusCharging =0x03,
    /**
     *  the battery is unknown
     */
    BlueSTSDKFeatureBatteryStatusUnknown =0x04,
    /**
     *  error state/battery not present
     */
     BlueSTSDKFeatureBatteryStatusError =0xFF
};

/**
 *  current battery status
 *
 *  @param data sample read from the node
 *
 *  @return current battery status
 */
+(BlueSTSDKFeatureBatteryStatus)getBatteryStatus:(BlueSTSDKFeatureSample*)data;

/**
 *  current battery status as a string
 *
 *  @param data sample read from the node
 *
 *  @return current battery status as a string
 */
+(NSString*)getBatteryStatusStr:(BlueSTSDKFeatureSample*)data;

/**
 *  current percentage of charg
 *
 *  @param data sample read from the node
 *
 *  @return battery percentage of charge
 */
+(float)getBatteryLevel:(BlueSTSDKFeatureSample*)data;

/**
 *  current battery voltage
 *
 *  @param data sample read from the node
 *
 *  @return battery voltage in mV
 */
+(float)getBatteryVoltage:(BlueSTSDKFeatureSample*)data;

/**
 *  battery current, if positive the battery is charging, if negative is discharging
 *
 *  @param data sample read from the node
 *
 *  @return battery current in mA
 */
+(float)getBatteryCurrent:(BlueSTSDKFeatureSample*)data;

/**
 * Ask to read the node battery capacity
 *
 * @return true if the request is sent
 */
-(BOOL)readBatteryCapacity;


/**
 * Ask to read the maximu node assorbed current
 *
 * @return true if the request is sent
 */
-(BOOL)readMaxAbsorbedCurrent;


/**
 * Add a delegate to receive the battery capacyt and the max absorbed current
 *
 * @param delegate object where notify the data
 */
-(void) addBatteryDelegate:(id<BlueSTSDKFeatureBatteryDelegate>)delegate NS_SWIFT_NAME(addBatteryDelegate(_:));


/**
 * Remove the delate
 *
 * @param delegate delegate to remove
 */
-(void) removeBatteryDelegate:(id<BlueSTSDKFeatureBatteryDelegate>)delegate NS_SWIFT_NAME(removeBatteryDelegate(_:));

@end

/**
 * Delegate used to notify the node battery capacity and the max current
 */
@protocol  BlueSTSDKFeatureBatteryDelegate <NSObject>


 /**
  *callback called when the battery capacity is read
  *
  *@param feature feature used to read the battery capacity
  *@param capacity battery capacity in mAh
  */
@optional -(void)didCapacityRead:(BlueSTSDKFeatureBattery *)feature
                        capacity:(uint16_t)capacity;

 /**
  *callback called when the max assorbed current is read
  *
  *@param feature feature used to read the value
  *@param current current in mA
  */
@optional -(void)didMaxAssorbedCurrentRead:(BlueSTSDKFeatureBattery *)feature
                                   current:(float)current;
@end

#endif
