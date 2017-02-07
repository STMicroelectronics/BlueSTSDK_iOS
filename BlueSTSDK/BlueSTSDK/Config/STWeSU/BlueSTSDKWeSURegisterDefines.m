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
#import "BlueSTSDKRegister.h"
#import "BlueSTSDKWeSURegisterDefines.h"

/**
 * This class help to get list of Registers available for The BlueST nodes
 * @par
 *     It define the Register list available for the node
 *
 * @author STMicroelectronics - Central Labs.
 * @version 1.0, 26 May 2015
 */
@implementation BlueSTSDKWeSURegisterDefines

/**
 * Returns a string containing a concise, human-readable description of this
 * object. In this case, the enum constant's name is returned.
 *
 * @return a printable representation of this object.
 */
#define ENUM_CASE(evalue)       \
case evalue:        \
ret = @#evalue; \
break;


+(NSString *)description:(BlueSTSDKWeSURegisterName_e)registerName {
    NSString * ret =  @""; //super.toString();
    //    strRet = strRet.substring(0, strRet.lastIndexOf("__"))
    //    .replace("_", " ")
    //    .replace("SW", "SOFTWARE")
    //    .replace("HW", "HARDWARE")
    //    .replace("CTRL", "");
    
    switch(registerName)
    {
            /*mandatory registers*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_FW_VER)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_LED_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR)
            
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BATTERY_LEVEL)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BATTERY_VOLTAGE)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_CURRENT)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_PWRMNG_STATUS)
            
            /*optional generic*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_TIMER_FREQ)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG)
            
            /*optional group A ctrls features*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0001)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0002)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0004)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0008)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0010)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0020)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0040)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0080)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0100)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0200)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0400)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0800)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_1000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_2000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_4000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_8000)

            /*optional group B ctrls features*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0001)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0002)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0004)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0008)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0010)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0020)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0040)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0080)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0100)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0200)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0400)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0800)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_1000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_2000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_4000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_8000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BLUENRG_INFO)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CALIBRATION_START)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MOTION_FX_CALIBRATION_LIC_STATUS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MOTION_AR_VALUE_LIC_STATUS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MOTION_CP_VALUE_LIC_STATUS)
            
            /*optional misc*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BLE_DEBUG_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_USB_DEBUG_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_CALIBRATION_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_CALIBRATION_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP)

            /*optional fullscale (FS) and output data rate (ODR)*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_FS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_ODR)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_FS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_ODR)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_FS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_ODR)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_FS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_ODR)
            
            /*optional commands*/
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_DFU_REBOOT)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_POWER_OFF)
        default:
            ret = @"";
            break;
    }
    
    return  ret;
}

/**
 * array that map the registers of BlueST nodes
 */
#define HASHMAP_ITEM(_name, _address, _size, _access, _target) [NSNumber numberWithInt:_name]: [BlueSTSDKRegister registerWithAddress:_address size:_size access:_access target:_target]

static NSDictionary * mapRegisters = nil;
//
+(void)initializeMapRegisters {
    mapRegisters = @{
                     /*Mandatory registers*/
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_FW_VER                       , 0x00, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_LED_CONFIG                   , 0x02, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME                 , 0x03, 8, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR                 , 0x0B, 3, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_ADDR_TYPE                , 0x0E, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BATTERY_LEVEL                , 0x03, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BATTERY_VOLTAGE              , 0x04, 2, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_CURRENT                      , 0x06, 2, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PWRMNG_STATUS                , 0x08, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     
                     /*optional generic*/
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG           , 0x20, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_TIMER_FREQ                   , 0x21, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG              , 0x22, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     /*optional group A ctrls features*/
                     //HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP         , 0x23, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0001   , 0x24, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0002   , 0x25, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0004   , 0x26, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0008   , 0x27, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0010   , 0x28, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0020   , 0x29, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0040   , 0x2A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0080   , 0x2B, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0100   , 0x2C, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0200   , 0x2D, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0400   , 0x2E, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0800   , 0x2F, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_1000   , 0x30, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_2000   , 0x31, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_4000   , 0x32, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_8000   , 0x33, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     /*optional group B ctrls features*/
                     //HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP         , 0x34, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0001   , 0x35, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0002   , 0x36, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0004   , 0x37, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0008   , 0x38, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0010   , 0x39, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0020   , 0x3A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0040   , 0x3B, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0080   , 0x3C, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0100   , 0x3D, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0200   , 0x3E, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0400   , 0x3F, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0800   , 0x40, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_1000   , 0x41, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_2000   , 0x42, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_4000   , 0x43, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_8000   , 0x44, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     /*optional misc*/
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_DEBUG_CONFIG             , 0x45, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_USB_DEBUG_CONFIG             , 0x46, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_CALIBRATION_MAP      , 0x47, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_CALIBRATION_MAP      , 0x48, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP         , 0x49, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP         , 0x4A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLUENRG_INFO                 , 0x4C, 2, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CALIBRATION_START,0x60, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     
                     /*optional fullscale (FS) and output data rate (ODR)*/
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_FS      , 0x74, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_ODR     , 0x75, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_FS          , 0x76, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_ODR         , 0x77, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_FS       , 0x78, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_ODR      , 0x79, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_FS           , 0x7A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_ODR          , 0x7B, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     
                     /*optional commands*/
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME                , 0x90, 4, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_DFU_REBOOT                   , 0xF0, 1, BlueSTSDK_REGISTER_ACCESS_W   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_POWER_OFF                    , 0xF2, 1, BlueSTSDK_REGISTER_ACCESS_W   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MOTION_FX_CALIBRATION_LIC_STATUS,0x8C, 1, BlueSTSDK_REGISTER_ACCESS_R , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MOTION_AR_VALUE_LIC_STATUS   , 0x8D, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_MOTION_CP_VALUE_LIC_STATUS   , 0x8E, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    )
                     
                     };
}

/**
 * Returns the register class of the available registers.
 *
 * @param name input RegistersName enum to find
 * @return the relative register if exist else null
 */
+(BlueSTSDKRegister *) lookUpWithRegisterName:(BlueSTSDKWeSURegisterName_e)name {
    if (mapRegisters == nil) {
        [BlueSTSDKWeSURegisterDefines initializeMapRegisters];
    }
    NSNumber * key = [NSNumber numberWithInteger:name];
    return (BlueSTSDKRegister *)mapRegisters[key];
}
+(BlueSTSDKRegister *) lookUpRegisterWithAddress:(NSInteger)address target:(BlueSTSDKRegisterTarget_e)target {
    if (mapRegisters == nil) {
        [BlueSTSDKWeSURegisterDefines initializeMapRegisters];
    }
    BlueSTSDKRegister *reg_target = nil;
    for(BlueSTSDKRegister *reg in mapRegisters) {
        if (reg.address == address && ((reg.target & target) == target))
        {
            reg_target = reg;
            break;
        }
    }
    return reg_target;
}
+(BlueSTSDKWeSURegisterName_e) lookUpRegisterNameWithAddress:(NSInteger)address target:(BlueSTSDKRegisterTarget_e)target {
    if (mapRegisters == nil) {
        [BlueSTSDKWeSURegisterDefines initializeMapRegisters];
    }
    NSNumber *key_target = [NSNumber numberWithInteger:BlueSTSDK_REGISTER_NAME_NONE];
    for(NSNumber *key in [mapRegisters allKeys] ) {
        BlueSTSDKRegister *reg = (BlueSTSDKRegister *)mapRegisters[key];
        if (reg.address == address && ((reg.target & target) == target))
        {
            key_target = key;
            break;
        }
    }
    return (BlueSTSDKWeSURegisterName_e)[key_target integerValue];
}

+(NSDictionary *)registers {
    return mapRegisters;
}

+(BlueSTSDKFwVersion*)extractFwVersion:(BlueSTSDKCommand *)answer{
    uint8_t data[answer.data.length];
    [answer.data getBytes:data length:answer.data.length];
    return [BlueSTSDKFwVersion versionMajor:(data[1] >> 4) & 0x0F
                                      minor:(data[1]) & 0x0F
                                      patch:(data[0] & 0xFF)];
}

+(BlueSTSDKWeSUFeatureConfig*)extractFeatureConfig:(BlueSTSDKCommand *)answer{
    uint8_t data[answer.data.length];
    [answer.data getBytes:data length:answer.data.length];
    
    return [BlueSTSDKWeSUFeatureConfig configWithSubsampling: data[1]
                                                   outputBLE:(data[0] & 0x04)== 0x04
                                                 outputUSART:(data[0] & 0x02)== 0x02
                                                   outputRAM:(data[0] & 0x80)== 0x80];
    
}

+(void)encodeFeaturConfing:(BlueSTSDKWeSUFeatureConfig*)config forCommand:(BlueSTSDKCommand *)writeReq{
    
    uint8_t data[2];
    data[1]=config.subsampling;
    data[0]=0;
    if(config.outputBLE)
        data[0] |= 0x04;
    if(config.outputUSART)
        data[0] |= 0x02;
    if(config.outputRAM)
        data[0] |= 0x80;
    
    writeReq.data = [NSData dataWithBytes:data length:2];
    
}


@end

