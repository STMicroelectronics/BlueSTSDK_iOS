//
//  W2STSDKCommand.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 16/06/14.
//   (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKCommand.h"

@implementation W2STSDKCommand

static const W2STSDKCommandRegister_t registers[W2STSDK_CTRL_REG_NUMBER_ALL] = {
    /*** EEPROM registers ***/
    //Application Configuration
    
    {W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME,           W2STSDK_CTRL_MEM_EEPROM, 0x00, 0x07, 8, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_BLE_PUB_ADDR,           W2STSDK_CTRL_MEM_EEPROM, 0x08, 0x0D, 6, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_AHRS_DATA_CRTL,         W2STSDK_CTRL_MEM_EEPROM, 0x0F, 0x0F, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_PWR_MODE_CRTL,          W2STSDK_CTRL_MEM_EEPROM, 0x0E, 0x0E, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_PWR_DATA_CTRL,          W2STSDK_CTRL_MEM_EEPROM, 0x10, 0x10, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_RAW_MOTION_DATA_CTRL,   W2STSDK_CTRL_MEM_EEPROM, 0x11, 0x11, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_TIMER_CTRL,             W2STSDK_CTRL_MEM_EEPROM, 0x12, 0x13, 2, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_LED_CTRL,               W2STSDK_CTRL_MEM_EEPROM, 0x15, 0x15, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_RADIO_TXPWR_CTRL,       W2STSDK_CTRL_MEM_EEPROM, 0x16, 0x16, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_EXT_GPIO_CTRLS,         W2STSDK_CTRL_MEM_EEPROM, 0x17, 0x1B, 5, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_RAW_ENV_CTRL,           W2STSDK_CTRL_MEM_EEPROM, 0x1C, 0x1C, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_ALGORITHM_CTRLS,        W2STSDK_CTRL_MEM_EEPROM, 0x6D, 0x74, 8, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_AUX_PERIPHERAL_CTRL,    W2STSDK_CTRL_MEM_EEPROM, 0x75, 0x80, 12, W2STSDKCommandRegisterRightsReadWrite},
    
    //DFU Control
    {W2STSDK_CTRL_REG_EEPROM_DFU_CTRL,               W2STSDK_CTRL_MEM_EEPROM, 0xF0, 0xF0, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_EEPROM_FW_CHECK,               W2STSDK_CTRL_MEM_EEPROM, 0xF1, 0xF2, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_EEPROM_FW_CHECK_2,             W2STSDK_CTRL_MEM_EEPROM, 0xF3, 0xF4, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_EEPROM_FW_LENGTH,              W2STSDK_CTRL_MEM_EEPROM, 0xF5, 0xF6, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_EEPROM_FW_CRC,                 W2STSDK_CTRL_MEM_EEPROM, 0xF6, 0xF7, 2, W2STSDKCommandRegisterRightsRead},
    
    /*** RAM registers ***/
    {W2STSDK_CTRL_REG_RAM_FW_VER,                    W2STSDK_CTRL_MEM_RAM,    0x00, 0x01, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_N_TICKS,                   W2STSDK_CTRL_MEM_RAM,    0x02, 0x03, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_CURR,                      W2STSDK_CTRL_MEM_RAM,    0x04, 0x05, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_BATT_VOLT,                 W2STSDK_CTRL_MEM_RAM,    0x06, 0x07, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_N_READ_POWER,              W2STSDK_CTRL_MEM_RAM,    0x08, 0x09, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_CHG_PERC,                  W2STSDK_CTRL_MEM_RAM,    0x0A, 0x0A, 1, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_PWR_MODE_STATUS,           W2STSDK_CTRL_MEM_RAM,    0x0B, 0x0E, 4, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_AHRS_DATA_CTRL,            W2STSDK_CTRL_MEM_RAM,    0x0F, 0x0F, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_RAM_PWR_DATA_CTRL,             W2STSDK_CTRL_MEM_RAM,    0x10, 0x10, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_RAM_RAW_MOTION_DATA_CTRL,      W2STSDK_CTRL_MEM_RAM,    0x11, 0x11, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_RAM_ENV_DATA_CTRL,             W2STSDK_CTRL_MEM_RAM,    0x1C, 0x1C, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_RAM_ERR_BLE_UPDATE,            W2STSDK_CTRL_MEM_RAM,    0x1E, 0x1F, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_TEMP_DATA,                 W2STSDK_CTRL_MEM_RAM,    0x24, 0x25, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_HUMIDITY_DATA,             W2STSDK_CTRL_MEM_RAM,    0x26, 0x27, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_PRESS_DATA,                W2STSDK_CTRL_MEM_RAM,    0x28, 0x29, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_ACC_X_DATA,                W2STSDK_CTRL_MEM_RAM,    0x2a, 0x2b, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_ACC_Y_DATA,                W2STSDK_CTRL_MEM_RAM,    0x2c, 0x2d, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_ACC_Z_DATA,                W2STSDK_CTRL_MEM_RAM,    0x2e, 0x2f, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_GYRO_X_DATA,               W2STSDK_CTRL_MEM_RAM,    0x30, 0x31, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_GYRO_Y_DATA,               W2STSDK_CTRL_MEM_RAM,    0x32, 0x33, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_GYRO_Z_DATA,               W2STSDK_CTRL_MEM_RAM,    0x34, 0x35, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_MAG_X_DATA,                W2STSDK_CTRL_MEM_RAM,    0x36, 0x37, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_MAG_Y_DATA,                W2STSDK_CTRL_MEM_RAM,    0x38, 0x39, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_MAG_Z_DATA,                W2STSDK_CTRL_MEM_RAM,    0x3a, 0x3b, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_BNRG_STATUS,               W2STSDK_CTRL_MEM_RAM,    0x40, 0x40, 1, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_AHRS_STATUS,               W2STSDK_CTRL_MEM_RAM,    0x42, 0x43, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_SW_DELAY,                  W2STSDK_CTRL_MEM_RAM,    0x44, 0x45, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_AHRS_DATA,                 W2STSDK_CTRL_MEM_RAM,    0x46, 0x53, 14, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_HW_CONF_CTRL,              W2STSDK_CTRL_MEM_RAM,    0x75, 0x75, 1, W2STSDKCommandRegisterRightsReadWrite},
    {W2STSDK_CTRL_REG_RAM_AUX_PERIPHERAL_CTRL,       W2STSDK_CTRL_MEM_RAM,    0x76, 0x76, 1, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_CLK_DFU,                   W2STSDK_CTRL_MEM_RAM,    0xA0, 0xA1, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_LP_DFU,                    W2STSDK_CTRL_MEM_RAM,    0xA2, 0xA3, 2, W2STSDKCommandRegisterRightsRead},
    {W2STSDK_CTRL_REG_RAM_DFU_LENGTH,                W2STSDK_CTRL_MEM_RAM,    0xA4, 0xA5, 2, W2STSDKCommandRegisterRightsRead},
};
+(W2STSDKCommandRegister_t)registerAtIndex:(NSUInteger)index {
    return registers[index];
}
+(W2STSDKCommandRegister_t)registerAtAddress:(NSUInteger)address memory:(W2STSDKCommandMemory_e)memory {
    int start = memory == W2STSDK_CTRL_MEM_EEPROM ? W2STSDK_CTRL_REG_EEPROM_FIRST : W2STSDK_CTRL_REG_RAM_FIRST;
    int end = memory == W2STSDK_CTRL_MEM_EEPROM ? W2STSDK_CTRL_REG_EEPROM_LAST : W2STSDK_CTRL_REG_RAM_LAST;
    int index = start;
    while ((address < registers[index].addr_start || registers[index].addr_end < address) && (address <= end)) {
        index++;
    }
    return registers[index];
}

-(W2STSDKCommandRegister_t)getReg {
    return [W2STSDKCommand registerAtAddress:self.ctrlFrame.addr memory:(self.ctrlFrame.ctrl.map.memory == 0 ? W2STSDK_CTRL_MEM_RAM : W2STSDK_CTRL_MEM_EEPROM)];
}

-(NSString *)description {
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [super description];
    
    [str appendString:@"\nFrame\n"];
    [str appendFormat:@"Ctrl: 0x%0.2X\n", self.ctrlFrame.ctrl.value];
    [str appendFormat:@"Addr: 0x%0.2X\n", self.ctrlFrame.addr];
    [str appendFormat:@"Err:  0x%0.2X\n", self.ctrlFrame.err];
    [str appendFormat:@"Len:  0x%0.2X\n", self.ctrlFrame.len];
    [str appendString:@"Payload: ["];
    for(int i=0;i<self.ctrlFrame.len*2;i++) {
        [str appendFormat:@"%0.2X", self.ctrlFrame.payload[i]];
    }
    [str appendString:@"]"];
    
    return str;
}
-(NSData *)data {
    unsigned char *p = (unsigned char*)&_ctrlFrame;
    unsigned char fl = W2STSDK_CTRL_FRAME_FRAME_SIZE(_ctrlFrame);
    //unsigned char pl = W2STSDK_CTRL_FRAME_PAYLOAD_SIZE(_frame);
    
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"Frame (0x%0.8X) [%d]: ", (uint)p, fl];
    for(int i=0;i<fl;i++) {
        [str appendFormat:@"%0.2X", p[i]];
    }
    NSLog(@"%@", str);
    
    return [[NSData alloc] initWithBytes:p length:fl];
}


-(void)commonInit {
}

/******** INIT ********/
-(id)initWithData:(NSData *)data len:(NSUInteger)len offset:(NSUInteger)offset {
    self = [super init];
    if (self && data) {
        [self commonInit];
        const unsigned char *bytes = (const unsigned char *)[data bytes];
        long len_data = (long)[data length];
        long _len = MIN(len_data - offset, len);
        memcpy((void *)&_ctrlFrame, (void *)(bytes+offset), _len);
    }
    return self;
}
-(id)initWithData:(NSData *)data len:(NSUInteger)len {
    return [self initWithData:data len:len offset:0];
}
-(id)initWithData:(NSData *)data {
    return [self initWithData:data len:[data length] offset:0];
}
-(id)initWithBytes:(const void *)bytes len:(NSUInteger)len offset:(NSUInteger)offset {
    self = [super init];
    if (self && bytes) {
        [self commonInit];
        memcpy((void *)&_ctrlFrame, (void *)(bytes+offset), len);
    }
    return self;
}
-(id)initWithBytes:(const void *)bytes len:(NSUInteger)len {
    return [self initWithBytes:bytes len:len offset:0];
}

-(id)initWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err len:(W2STSDKCommandRegisterLen_t)len payload:(NSData *)payload {
    self = [super init];
    if (self) {
        [self commonInit];
        [self configWithCtrl:ctrl addr:addr err:err len:len payload:payload];
    }
    return self;
}
-(id)initWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err payload:(NSData *)payload {
    self = [super init];
    if (self) {
        [self commonInit];
        [self configWithCtrl:ctrl addr:addr err:err payload:payload];
    }
    return self;
}

/******** CONFIG ********/
-(void)configWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err len:(W2STSDKCommandRegisterLen_t)len payload:(NSData *)payload {
    _ctrlFrame.ctrl.value = ctrl.value;
    _ctrlFrame.addr = addr;
    _ctrlFrame.err = err;
    _ctrlFrame.len = len; //num register 16bits
    memset(_ctrlFrame.payload, 0x00, W2STSDK_CTRL_FRAME_PAYLOAD_SIZE_MAX);
    
    if (payload && payload.length > 0) {
        int s = MIN((int)payload.length, W2STSDK_CTRL_FRAME_PAYLOAD_SIZE_MAX);
        [payload getBytes:_ctrlFrame.payload length:s];
    }
}
-(void)configWithCtrl:(W2STSDKCommandRegisterCtrl_t)ctrl addr:(W2STSDKCommandRegisterAddr_t)addr err:(W2STSDKCommandRegisterErr_t)err payload:(NSData *)payload {
    [self configWithCtrl:ctrl addr:addr err:err len:0 payload:nil];
    [self configWithPayload:payload];
}
-(void)configWithPayload:(NSData *)data {
    NSUInteger n = data.length;
    assert(data);
    _ctrlFrame.len = (n + 1) / 2; //set to the next even number and set the size in 16bit (2bytes)
                                //if even => n / 2 the same of (n+1) / 2
                                //if odd => (n+1) / 2
    [data getBytes:_ctrlFrame.payload length:n];
}

//static methods
+(W2STSDKCommandRegisterCtrl_t)controlWithPending:(BOOL)pending eeprom:(BOOL)memory write:(BOOL)operation error:(BOOL)error ack:(BOOL)ack fragment:(BOOL)fragment {
    W2STSDKCommandRegisterCtrl_t ctrl;
    ctrl.map.pending    = pending   ? 1 : 0;
    ctrl.map.memory     = memory    ? 1 : 0;
    ctrl.map.operation  = operation ? 1 : 0;
    ctrl.map.error      = error     ? 1 : 0;
    ctrl.map.ack        = ack       ? 1 : 0;
    ctrl.map.fragment   = fragment  ? 1 : 0;
    ctrl.map.reserved   = 0;
    return ctrl;
}

/******** CREATE ********/

/* Create with NSData */
+(W2STSDKCommand *)createWithData:(NSData *)data len:(NSUInteger)len offset:(NSUInteger)offset {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithData:data len:len offset:offset];
    return cmd;
}
+(W2STSDKCommand *)createWithData:(NSData *)data len:(NSUInteger)len {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithData:data len:len];
    return cmd;
}
+(W2STSDKCommand *)createWithData:(NSData *)data {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithData:data];
    return cmd;
}
/* Create with Bytes */
+(W2STSDKCommand *)createWithBytes:(const void *)bytes len:(NSUInteger)len offset:(NSUInteger)offset {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithBytes:bytes len:len offset:offset];
    return cmd;
}
+(W2STSDKCommand *)createWithBytes:(const void *)bytes len:(NSUInteger)len {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithBytes:bytes len:len];
    return cmd;
}

/* Create with Fields */
+(W2STSDKCommand *)createWithCtrl:(NSUInteger)ctrlvalue  addr:(NSUInteger)addr err:(NSUInteger)err payload:(NSData *)payload {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithCtrl:(W2STSDKCommandRegisterCtrl_t){ctrlvalue}
                                                    addr:(W2STSDKCommandRegisterAddr_t)addr
                                                     err:(W2STSDKCommandRegisterErr_t)err
                                                 payload:payload];
    return cmd;
}
+(W2STSDKCommand *)createWithCtrl:(NSUInteger)ctrlvalue  addr:(NSUInteger)addr err:(NSUInteger)err len:(NSUInteger)len payload:(NSData *)payload {
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithCtrl:(W2STSDKCommandRegisterCtrl_t){ctrlvalue}
                                                    addr:(W2STSDKCommandRegisterAddr_t)addr
                                                     err:(W2STSDKCommandRegisterErr_t)err
                                                     len:(W2STSDKCommandRegisterLen_t)len
                                                 payload:payload];
    return cmd;
}
/* Create with Index */
+(W2STSDKCommand *)createWithReg:(W2STSDKCommandRegister_e)regEnum operation:(W2STSDKCommandOperation_e)operation payload:(NSData *)payload {
    W2STSDKCommandRegister_t reg = registers[(int)regEnum];
    W2STSDKCommandRegisterCtrl_t ctrl = [W2STSDKCommand controlWithPending:YES eeprom:reg.mem write:(operation == W2STSDK_CTRL_OPT_WRITE ? YES : NO) error:NO ack:YES fragment:NO];
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 len:reg.len payload:payload];
    
    return cmd;
}

/*
+(W2STSDKCommand *)createReadFirmware {
    W2STSDKCommandRegisterCtrl_t ctrl = [W2STSDKCommand controlWithPending:YES eeprom:NO write:NO error:NO ack:NO fragment:NO];
    W2STSDKCommandRegister_t reg = registers[W2STSDK_CTRL_REG_RAM_FW_VER];
    //NSData *payload = [[NSData alloc] initWithBytes:nil length:0];
    
    W2STSDKCommand *cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 len:reg.len];
    
    return cmd;
}
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation name:(NSString *)name {
    W2STSDKCommandRegisterCtrl_t ctrl;
    ctrl = [W2STSDKCommand controlWithPending:YES eeprom:YES write:(BOOL)operation error:NO ack:!(BOOL)operation fragment:NO];
    W2STSDKCommand *cmd = nil;
    unsigned char buf[128];
    memset(buf, 0x00, 128);
    
    W2STSDKCommandRegister_t reg = registers[W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME];
    
    if (operation == W2STSDK_CTRL_OPT_WRITE) {
        const char *s = [name cStringUsingEncoding:NSASCIIStringEncoding];
        int max_len = reg.len<<1;
        unsigned int len = MIN(max_len, (unsigned int)[name length]);
        buf[0] = 9;
        memcpy(buf+1, s, len);
        NSData *payload = [[NSData alloc] initWithBytes:&buf length:max_len]; //write 8 registers, 8*2 bytes
        cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 payload:payload];
    }
    else {
        cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 len:reg.len];
    }
    
    return cmd;
}
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation address:(NSString *)address {
    return nil;
}
+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation firmware:(BOOL)flag {
    return nil;
}

+(W2STSDKCommand *)create:(W2STSDKCommandOperation_e)operation led:(BOOL)led {
    unsigned short payloadValue = led ? 0x0000 : 0x0010; // 0x0012;
    W2STSDKCommandRegisterCtrl_t ctrl = [W2STSDKCommand controlWithPending:YES eeprom:YES write:(BOOL)operation error:NO ack:!(BOOL)operation fragment:NO];
    W2STSDKCommand *cmd = nil;

    W2STSDKCommandRegister_t reg = registers[W2STSDK_CTRL_REG_EEPROM_LED_CTRL];
    if (operation == W2STSDK_CTRL_OPT_WRITE) {
        NSData *payload = [[NSData alloc] initWithBytes:&payloadValue length:sizeof(payloadValue)];
        cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 payload:payload];
    }
    else {
        cmd = [[W2STSDKCommand alloc] initWithCtrl:ctrl addr:reg.addr_start err:0 len:reg.len];
    }
    
    return cmd;
}
*/
@end
