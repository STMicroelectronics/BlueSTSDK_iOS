//
//  W2STSDKCommand.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 16/06/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"

#define W2STSDK_CTRL_FRAME_IS_READ(frame) (frame.ctrl.map.operation == W2STSDK_CTRL_OPT_READ)
#define W2STSDK_CTRL_FRAME_IS_WRITE(frame) (frame.ctrl.map.operation == W2STSDK_CTRL_OPT_WRITE)

#define W2STSDK_CTRL_FRAME_PAYLOAD_SIZE_MAX 60 //bytes
#define W2STSDK_CTRL_FRAME_HEADER_SIZE 4 //bytes
#define W2STSDK_CTRL_FRAME_PAYLOAD_SIZE(frame) (W2STSDK_CTRL_FRAME_IS_READ(frame) ? 0 : (frame.len)<<1) //frame.len indicates the number of register to 16bits (2bytes) have to write (payload size) or read payload = empty
#define W2STSDK_CTRL_FRAME_FRAME_SIZE(frame) (W2STSDK_CTRL_FRAME_IS_READ(frame) ? W2STSDK_CTRL_FRAME_HEADER_SIZE : W2STSDK_CTRL_FRAME_HEADER_SIZE + W2STSDK_CTRL_FRAME_PAYLOAD_SIZE(frame))

typedef unsigned char W2STSDKCommandRegisterCtrlBase_t;
typedef unsigned char W2STSDKCommandRegisterAddr_t;
typedef unsigned char W2STSDKCommandRegisterErr_t;
typedef unsigned char W2STSDKCommandRegisterLen_t;
typedef unsigned char W2STSDKCommandRegisterPayload_t;

typedef NS_ENUM(BOOL, W2STSDKCommandMemory_e) {
    W2STSDK_CTRL_MEM_EEPROM = YES,
    W2STSDK_CTRL_MEM_RAM = NO
};
typedef NS_ENUM(BOOL, W2STSDKCommandOperation_e) {
    W2STSDK_CTRL_OPT_READ = NO,
    W2STSDK_CTRL_OPT_WRITE = YES
};
typedef NS_ENUM(unsigned char, W2STSDKCommandRegisterRights_e) {
    W2STSDKCommandRegisterRightsRead  = 1,
    W2STSDKCommandRegisterRightsWrite = 2,
    W2STSDKCommandRegisterRightsReadWrite  = W2STSDKCommandRegisterRightsRead | W2STSDKCommandRegisterRightsWrite,
};


typedef NS_ENUM(unsigned char, W2STSDKCommandRegister_e) {
    W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME,
    W2STSDK_CTRL_REG_EEPROM_BLE_PUB_ADDR,
    W2STSDK_CTRL_REG_EEPROM_AHRS_DATA_CRTL,
    W2STSDK_CTRL_REG_EEPROM_PWR_MODE_CRTL,
    W2STSDK_CTRL_REG_EEPROM_PWR_DATA_CTRL,
    W2STSDK_CTRL_REG_EEPROM_RAW_MOTION_DATA_CTRL,
    W2STSDK_CTRL_REG_EEPROM_TIMER_CTRL,
    W2STSDK_CTRL_REG_EEPROM_LED_CTRL,
    W2STSDK_CTRL_REG_EEPROM_RADIO_TXPWR_CTRL,
    W2STSDK_CTRL_REG_EEPROM_EXT_GPIO_CTRLS,
    W2STSDK_CTRL_REG_EEPROM_RAW_ENV_CTRL,
    W2STSDK_CTRL_REG_EEPROM_ALGORITHM_CTRLS,
    W2STSDK_CTRL_REG_EEPROM_AUX_PERIPHERAL_CTRL,
    W2STSDK_CTRL_REG_EEPROM_DFU_CTRL,
    W2STSDK_CTRL_REG_EEPROM_FW_CHECK,
    W2STSDK_CTRL_REG_EEPROM_FW_CHECK_2,
    W2STSDK_CTRL_REG_EEPROM_FW_LENGTH,
    W2STSDK_CTRL_REG_EEPROM_FW_CRC,
    W2STSDK_CTRL_REG_RAM_FW_VER,
    W2STSDK_CTRL_REG_RAM_N_TICKS,
    W2STSDK_CTRL_REG_RAM_CURR,
    W2STSDK_CTRL_REG_RAM_BATT_VOLT,
    W2STSDK_CTRL_REG_RAM_N_READ_POWER,
    W2STSDK_CTRL_REG_RAM_CHG_PERC,
    W2STSDK_CTRL_REG_RAM_PWR_MODE_STATUS,
    W2STSDK_CTRL_REG_RAM_AHRS_DATA_CTRL,
    W2STSDK_CTRL_REG_RAM_PWR_DATA_CTRL,
    W2STSDK_CTRL_REG_RAM_RAW_MOTION_DATA_CTRL,
    W2STSDK_CTRL_REG_RAM_ENV_DATA_CTRL,
    W2STSDK_CTRL_REG_RAM_ERR_BLE_UPDATE,
    W2STSDK_CTRL_REG_RAM_TEMP_DATA,
    W2STSDK_CTRL_REG_RAM_HUMIDITY_DATA,
    W2STSDK_CTRL_REG_RAM_PRESS_DATA,
    W2STSDK_CTRL_REG_RAM_ACC_X_DATA,
    W2STSDK_CTRL_REG_RAM_ACC_Y_DATA,
    W2STSDK_CTRL_REG_RAM_ACC_Z_DATA,
    W2STSDK_CTRL_REG_RAM_GYRO_X_DATA,
    W2STSDK_CTRL_REG_RAM_GYRO_Y_DATA,
    W2STSDK_CTRL_REG_RAM_GYRO_Z_DATA,
    W2STSDK_CTRL_REG_RAM_MAG_X_DATA,
    W2STSDK_CTRL_REG_RAM_MAG_Y_DATA,
    W2STSDK_CTRL_REG_RAM_MAG_Z_DATA,
    W2STSDK_CTRL_REG_RAM_BNRG_STATUS,
    W2STSDK_CTRL_REG_RAM_AHRS_STATUS,
    W2STSDK_CTRL_REG_RAM_SW_DELAY,
    W2STSDK_CTRL_REG_RAM_AHRS_DATA,
    W2STSDK_CTRL_REG_RAM_HW_CONF_CTRL,
    W2STSDK_CTRL_REG_RAM_AUX_PERIPHERAL_CTRL,
    W2STSDK_CTRL_REG_RAM_CLK_DFU,
    W2STSDK_CTRL_REG_RAM_LP_DFU,
    W2STSDK_CTRL_REG_RAM_DFU_LENGTH,
    W2STSDK_CTRL_REG_FAKE = 0xFF
};

#define W2STSDK_CTRL_REG_EEPROM_FIRST W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME
#define W2STSDK_CTRL_REG_EEPROM_LAST  W2STSDK_CTRL_REG_EEPROM_FW_CRC
#define W2STSDK_CTRL_REG_RAM_FIRST    W2STSDK_CTRL_REG_RAM_FW_VER
#define W2STSDK_CTRL_REG_RAM_LAST     W2STSDK_CTRL_REG_RAM_DFU_LENGTH

#define W2STSDK_CTRL_REG_NUMBER_ALL (W2STSDK_CTRL_REG_RAM_LAST+1)
#define W2STSDK_CTRL_REG_NUMBER(EEPROM) ((EEPROM) ? (W2STSDK_CTRL_REG_EEPROM_LAST - W2STSDK_CTRL_REG_EEPROM_FIRST + 1) : (W2STSDK_CTRL_REG_RAM_LAST - W2STSDK_CTRL_REG_RAM_FIRST + 1))


typedef struct {
    W2STSDKCommandRegister_e reg;
    W2STSDKCommandMemory_e mem;
    W2STSDKCommandRegisterAddr_t addr_start;
    W2STSDKCommandRegisterAddr_t addr_end;
    W2STSDKCommandRegisterLen_t len; //num registers (so it is a length 1 = 2 bytes in payload)
    W2STSDKCommandRegisterRights_e rights;
} W2STSDKCommandRegister_t;

typedef struct {
    unsigned char reserved: 2;
    unsigned char fragment:1;
    unsigned char ack: 1;
    
    unsigned char error:1;
    unsigned char operation:1;
    unsigned char memory:1;
    unsigned char pending:1;
} W2STSDKCommandRegisterCtrlMap_t;

typedef struct {
    union {
        W2STSDKCommandRegisterCtrlBase_t value;
        W2STSDKCommandRegisterCtrlMap_t map;
    };
} W2STSDKCommandRegisterCtrl_t;

typedef struct {
    W2STSDKCommandRegisterCtrl_t     ctrl;
    W2STSDKCommandRegisterAddr_t     addr;
    W2STSDKCommandRegisterErr_t      err;
    W2STSDKCommandRegisterLen_t      len;
    W2STSDKCommandRegisterPayload_t  payload[W2STSDK_CTRL_FRAME_PAYLOAD_SIZE_MAX];
} W2STSDKCommandFrame_t;

@interface W2STSDKCommand : NSObject

@property (weak, nonatomic) W2STSDKNode *node;
@property (assign, nonatomic) W2STSDKCommandFrame_t ctrlFrame;
//@property (assign, readonly) W2STSDKCommandRegister_t reg;
-(W2STSDKCommandRegister_t)getReg;

-(NSData *)data;

+(W2STSDKCommandRegister_t)registerAtIndex:(NSUInteger)index;
+(W2STSDKCommandRegister_t)registerAtAddress:(NSUInteger)address memory:(W2STSDKCommandMemory_e)memory;

-(id)initWithData:(NSData *)data len:(NSUInteger)len offset:(NSUInteger)offset;
-(id)initWithData:(NSData *)data len:(NSUInteger)len;
-(id)initWithData:(NSData *)data;
-(id)initWithBytes:(const void *)bytes len:(NSUInteger)len offset:(NSUInteger)offset;
-(id)initWithBytes:(const void *)bytes len:(NSUInteger)len;
-(id)initWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err len:(W2STSDKCommandRegisterLen_t)len payload:(NSData *)payload;
-(id)initWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err payload:(NSData *)payload;
-(void)configWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err len:(W2STSDKCommandRegisterLen_t)len payload:(NSData *)payload;
-(void)configWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err payload:(NSData *)payload;
-(void)configWithPayload:(NSData *)payload;

+(W2STSDKCommandRegisterCtrl_t)controlWithPending:(BOOL)pending eeprom:(BOOL)memory write:(BOOL)operation error:(BOOL)error ack:(BOOL)ack fragment:(BOOL)fragment;

+(W2STSDKCommand *)createWithData:(NSData *)data len:(NSUInteger)len offset:(NSUInteger)offset;
+(W2STSDKCommand *)createWithData:(NSData *)data len:(NSUInteger)len;
+(W2STSDKCommand *)createWithData:(NSData *)data;
+(W2STSDKCommand *)createWithBytes:(const void *)bytes len:(NSUInteger)len offset:(NSUInteger)offset;
+(W2STSDKCommand *)createWithBytes:(const void *)bytes len:(NSUInteger)len;

+(W2STSDKCommand *)createWithCtrl:(NSUInteger)ctrlvalue  addr:(NSUInteger)addr err:(NSUInteger)err payload:(NSData *)payload;
+(W2STSDKCommand *)createWithCtrl:(NSUInteger)ctrlvalue  addr:(NSUInteger)addr err:(NSUInteger)err len:(NSUInteger)len payload:(NSData *)payload;
+(W2STSDKCommand *)createWithReg:(W2STSDKCommandRegister_e)regEnum operation:(W2STSDKCommandOperation_e)operation payload:(NSData *)payload;

/*
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation name:(NSString *)name;
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation address:(NSString *)address;
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation firmware:(BOOL)flag;
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation led:(BOOL)led;
*/

@end
