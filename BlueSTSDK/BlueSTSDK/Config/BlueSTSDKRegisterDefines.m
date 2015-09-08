//
//  BlueSTSDKRegisterDefine.c
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKRegisterDefines.h"
#import "BlueSTSDKRegister.h"

/**
 * This class help to get list of Registers available for The W2ST devices
 * @par
 *     It define the Register list available for the device
 *
 * @author STMicroelectronics - Central Labs.
 * @version 1.0, 26 May 2015
 */
@implementation BlueSTSDKRegisterDefines

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


+(NSString *)description:(BlueSTSDKRegisterName_e)registerName {
    NSString * ret =  @""; //super.toString();
    //    strRet = strRet.substring(0, strRet.lastIndexOf("__"))
    //    .replace("_", " ")
    //    .replace("SW", "SOFTWARE")
    //    .replace("HW", "HARDWARE")
    //    .replace("CTRL", "");
    
    switch(registerName)
    {
            /*Mandatory registers*/
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
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURES_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0001)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0002)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0004)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0008)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0010)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0020)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0040)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0080)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0100)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0200)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0400)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0800)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_1000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_2000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_4000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_8000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURES_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0001)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0002)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0004)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0008)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0010)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0020)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0040)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0080)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0100)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0200)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0400)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0800)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_1000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_2000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_4000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_8000)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_BLE_DEBUG_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_USB_DEBUG_CONFIG)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION_MAP)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION_MAP)
            
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_DFU_REBOOT)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION_STATUS)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION)
            ENUM_CASE(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION_STATUS)
        default:
            ret = @"";
            break;
    }
    
    return  ret;
}

/**
 * array that map the registers of W2ST devices
 */
#define HASHMAP_ITEM(_name, _address, _size, _access, _target) [NSNumber numberWithInt:_name]: [BlueSTSDKRegister registerWithAddress:_address size:_size access:_access target:_target]

static NSDictionary * mapRegisters = nil;
//
+(void)initializeMapRegisters {
    mapRegisters = @{
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_FW_VER                  , 0x00, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_LED_CONFIG              , 0x02, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME            , 0x03, 8, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR            , 0x0B, 3, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BATTERY_LEVEL           , 0x03, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BATTERY_VOLTAGE         , 0x04, 2, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_CURRENT                 , 0x06, 2, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PWRMNG_STATUS           , 0x08, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG      , 0x20, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_TIMER_FREQ              , 0x21, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG         , 0x22, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURES_MAP         , 0x23, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0001   , 0x24, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0002   , 0x25, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0004   , 0x26, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0008   , 0x27, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0010   , 0x28, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0020   , 0x29, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0040   , 0x2A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0080   , 0x2B, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0100   , 0x2C, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0200   , 0x2D, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0400   , 0x2E, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_0800   , 0x2F, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_1000   , 0x30, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_2000   , 0x31, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_4000   , 0x32, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_FEATURE_CTRLS_8000   , 0x33, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURES_MAP         , 0x34, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0001   , 0x35, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0002   , 0x36, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0004   , 0x37, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0008   , 0x38, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0010   , 0x39, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0020   , 0x3A, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0040   , 0x3B, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0080   , 0x3C, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0100   , 0x3D, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0200   , 0x3E, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0400   , 0x3F, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_0800   , 0x40, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_1000   , 0x41, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_2000   , 0x42, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_4000   , 0x43, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_FEATURE_CTRLS_8000   , 0x44, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_BLE_DEBUG_CONFIG        , 0x45, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_USB_DEBUG_CONFIG        , 0x46, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_BOTH       ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION_MAP      , 0x47, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION_MAP      , 0x48, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_PERSISTENT ),
                     
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_DFU_REBOOT              , 0xF0, 1, BlueSTSDK_REGISTER_ACCESS_W   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION          , 0xF1, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_HW_CALIBRATION_STATUS   , 0xF2, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION          , 0xF3, 1, BlueSTSDK_REGISTER_ACCESS_RW  , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     HASHMAP_ITEM(BlueSTSDK_REGISTER_NAME_SW_CALIBRATION_STATUS   , 0xF4, 1, BlueSTSDK_REGISTER_ACCESS_R   , BlueSTSDK_REGISTER_TARGET_SESSION    ),
                     };
}

/**
 * Returns the register class of the available registers.
 *
 * @param name input RegistersName enum to find
 * @return the relative register if exist else null
 */
+(BlueSTSDKRegister *) lookUpWithRegisterName:(BlueSTSDKRegisterName_e)name {
    if (mapRegisters == nil) {
        [BlueSTSDKRegisterDefines initializeMapRegisters];
    }
    NSNumber * key = [NSNumber numberWithInteger:name];
    return (BlueSTSDKRegister *)mapRegisters[key];
}
+(BlueSTSDKRegister *) lookUpRegisterWithAddress:(NSInteger)address target:(BlueSTSDKRegisterTarget_e)target {
    if (mapRegisters == nil) {
        [BlueSTSDKRegisterDefines initializeMapRegisters];
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
+(BlueSTSDKRegisterName_e) lookUpRegisterNameWithAddress:(NSInteger)address target:(BlueSTSDKRegisterTarget_e)target {
    if (mapRegisters == nil) {
        [BlueSTSDKRegisterDefines initializeMapRegisters];
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
    return (BlueSTSDKRegisterName_e)[key_target integerValue];
}
+(NSDictionary *)registers {
    return mapRegisters;
}
@end

