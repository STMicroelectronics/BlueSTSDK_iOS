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

#import "BlueSTSDKDebug.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureAutoConfigurable.h"
#import "../Util/NSData+NumberConversion.h"

/**
 * value used for start the configuration procedure
 */
#define FEATURE_COMMAND_START_CONFIGURATION 0x00
/**
 * value used for stop the configuration procedure
 */
#define FEATURE_COMMAND_STOP_CONFIGURATION 0x01
/**
 * value used for ask the current configuration status/goodness
 */
#define FEATURE_COMMAND_GET_CONFIGURATION_STATUS 0xFF

/**
 *  queue used for notify things to the delegate
 */
static dispatch_queue_t sNotificationQueue;

@interface BlueSTSDKFeatureAutoConfigurable(BlueSTSDKDebugOutputDelegate) <BlueSTSDKDebugOutputDelegate>

@end

@implementation BlueSTSDKFeatureAutoConfigurable{
    /**
     *  Set of delegate where notify the change on the confuguration
     */
    NSMutableSet *mFeatureAutoConfDelegates;
}

-(instancetype) initWhitNode: (BlueSTSDKNode*)node name:(NSString*)name{
    self = [super initWhitNode:node name:name];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKFeatureAutoConfigurable",
                                                   DISPATCH_QUEUE_CONCURRENT);
    });
    _isConfigured=NO;
    mFeatureAutoConfDelegates = [NSMutableSet set];
    return self;
}

/**
 *  notify to all the registered delegate that the configuration process starts
 */
-(void)notifyAutoConfStart{
    for (id<BlueSTSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
        if( [delegate respondsToSelector:@selector(didAutoConfigurationStart:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didAutoConfigurationStart: self];
            });
        }//if
    }//for
}

/**
 *  notify to all the registered delegate that the configuration process has a 
 *  new status
 *
 *  @param status new configuation status
 */
-(void)notifyAutoConfStopWithStatus:(int32_t)status{
    for (id<BlueSTSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
         if( [delegate respondsToSelector:@selector(didConfigurationFinished:status:)]){
             dispatch_async(sNotificationQueue, ^(){
                 [delegate didConfigurationFinished:self status:status];
             });
         }//if
    }//for
}

/**
 *  notify to all the registered delegate that the config
 *
 *  @param newStatus new confuguarion status
 */
-(void) notifyAutoConfChangeStatus:(int32_t)newStatus{
    for (id<BlueSTSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
        if( [delegate respondsToSelector:@selector(didAutoConfigurationChange:status:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didAutoConfigurationChange:self status:newStatus];
            });
        }//if
    }//for
}

-(BOOL) startAutoConfiguration{
    BOOL sendMessage = [self sendCommand:FEATURE_COMMAND_START_CONFIGURATION data:nil];
    BlueSTSDKNode *node = self.parentNode;

    if(!sendMessage && node.type == BlueSTSDKNodeTypeSensor_Tile_Box){
        sendMessage = true;
        BlueSTSDKDebug *console = node.debugConsole;
        [console addDebugOutputDelegate:self];
        [console writeMessage:@"startMagnCalib"];
    }
    
    if(sendMessage)
        [self notifyAutoConfStart];
    return sendMessage;
}
    
-(BOOL) requestAutoConfigurationStatus{
    return [self sendCommand:FEATURE_COMMAND_GET_CONFIGURATION_STATUS data:nil];
}
    
-(BOOL) stopAutoConfiguration{
    return [self sendCommand:FEATURE_COMMAND_STOP_CONFIGURATION data:nil];
}

-(void) addFeatureConfigurationDelegate:(id<BlueSTSDKFeatureAutoConfigurableDelegate>)delegate{
    [mFeatureAutoConfDelegates addObject:delegate];
}

-(void) removeFeatureConfigurationDelegate:(id<BlueSTSDKFeatureAutoConfigurableDelegate>)delegate{
    [mFeatureAutoConfDelegates removeObject:delegate];
}

/**
 *  this function is called when the node rensponse to a command, for this feature
 * it extarct the status and call the correct delegate. if the status is 100 the
 * feature is considered configurated and the stop signal is send
 *
 *  @param timestamp   package id
 *  @param commandType command type
 *  @param data        command data
 */
-(void) parseCommandResponseWithTimestamp:(uint64_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data{
    uint8_t status = [data extractUInt8FromOffset:0];
    if(commandType == FEATURE_COMMAND_STOP_CONFIGURATION){
        [self notifyAutoConfStopWithStatus:status];
        if(status==100)
            _isConfigured=YES;
    }else if(commandType == FEATURE_COMMAND_GET_CONFIGURATION_STATUS){
        [self notifyAutoConfChangeStatus:status];
        if(status==100){
            _isConfigured=YES;
            [self notifyAutoConfStopWithStatus:status];
        }else if (status==0){
            _isConfigured=NO;
        }//if eelse
    }else
        //if is an unknow command call the super method
        [super parseCommandResponseWithTimestamp:timestamp
                                        commandType:commandType
                                               data:data];
}//parseCommandResponseWithTimestamp

@end

@implementation BlueSTSDKFeatureAutoConfigurable(BlueSTSDKDebugOutputDelegate)

    - (void)debug:(nonnull BlueSTSDKDebug *)debug didStdOutReceived:(nonnull NSString *)msg {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"magnCalibStatus (\\d+)"
                                                                               options:0
                                                                                 error:&error];
        if(error!=nil){
            return;
        }
        NSArray *matches = [regex matchesInString:msg
                                          options:0
                                            range:NSMakeRange(0, [msg length])];
        
        NSTextCheckingResult *match = [matches firstObject];
        if(match == nil){
            return ;
        }
        [debug removeDebugOutputDelegate:self];
        NSRange statuRange = [match rangeAtIndex:1];
        uint8_t status = (uint8_t )([msg substringWithRange:statuRange].intValue);
        NSData *statusData = [ NSData dataWithBytes:&status length:1];
        [self parseCommandResponseWithTimestamp:0 commandType:FEATURE_COMMAND_GET_CONFIGURATION_STATUS data:statusData];
        
        
    }

- (void)debug:(nonnull BlueSTSDKDebug *)debug didStdErrReceived:(nonnull NSString *)msg {
}

- (void)debug:(nonnull BlueSTSDKDebug *)debug didStdInSend:(nonnull NSString *)msg error:(nullable NSError *)error {
    
}

@end


/*
 private class CalibrationSensorTileBox implements Debug.DebugOutputListener{
 
 private Debug mConsole;
 private final Pattern STATUS_PARSER = Pattern.compile("magnCalibStatus (\\d+)");
 
 public CalibrationSensorTileBox(Debug console){
 mConsole = console;
 
 }
 
 void startCalibration(){
 mConsole.addDebugOutputListener(this);
 mConsole.write("startMagnCalib");
 }
 
 void getCalibrationStatus(){
 mConsole.write("getMagnCalibStatus");
 }
 
 @Override
 public void onStdOutReceived(@NonNull Debug debug, @NonNull String message) {
 Matcher matcher = STATUS_PARSER.matcher(message);
 if (!matcher.matches())
 return;
 mConsole.removeDebugOutputListener(this);
 byte calibStatus = Byte.parseByte(matcher.group(1));
 parseCommandResponse(0,FEATURE_COMMAND_GET_CONFIGURATION_STATUS,
 new byte[]{calibStatus});
 }
 
 @Override
 public void onStdErrReceived(@NonNull Debug debug, @NonNull String message) {
 
 }
 
 @Override
 public void onStdInSent(@NonNull Debug debug, @NonNull String message, boolean writeResult) {
 
 }
 }
 */
                                                                                
                                                                                
