//
//  W2STSDKFeatureAutoConfigurable.m
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureAutoConfigurable.h"
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

@implementation W2STSDKFeatureAutoConfigurable{
    /**
     *  Set of delegate where notify the change on the confuguration
     */
    NSMutableSet *mFeatureAutoConfDelegates;
}

-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name{
    self = [super initWhitNode:node name:name];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STSDKFeatureAutoConfigurable",
                                                   DISPATCH_QUEUE_CONCURRENT);
    });
    
    _isConfigurated=NO;
    mFeatureAutoConfDelegates = [NSMutableSet set];
    return self;
}

/**
 *  notify to all the registered delegate that the configuration process starts
 */
-(void)notifyAutoConfStart{
    for (id<W2STSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
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
    for (id<W2STSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
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
 *  @param newStatus <#newStatus description#>
 */
-(void) notifyAutoConfChangeStatus:(int32_t)newStatus{
    for (id<W2STSDKFeatureAutoConfigurableDelegate> delegate in mFeatureAutoConfDelegates) {
        if( [delegate respondsToSelector:@selector(didAutoConfigurationChange:status:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didAutoConfigurationChange:self status:newStatus];
            });
        }//if
    }//for
}

-(BOOL) startAutoConfiguration{
    BOOL sendMessage = [self sendCommand:FEATURE_COMMAND_START_CONFIGURATION data:nil];
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

-(void) addFeatureConfigurationDelegate:(id<W2STSDKFeatureAutoConfigurableDelegate>)delegate{
    [mFeatureAutoConfDelegates addObject:delegate];
}

-(void) removeFeatureConfigurationDelegate:(id<W2STSDKFeatureAutoConfigurableDelegate>)delegate{
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
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data{
    uint8_t status = [data extractUInt8FromOffset:0];
    if(commandType == FEATURE_COMMAND_STOP_CONFIGURATION){
        [self notifyAutoConfStopWithStatus:status];
        if(status==100)
            _isConfigurated=YES;
    }else if(commandType == FEATURE_COMMAND_GET_CONFIGURATION_STATUS){
        [self notifyAutoConfChangeStatus:status];
        if(status==100){
            _isConfigurated=YES;
            [self notifyAutoConfStopWithStatus:status];
        }else if (status==0){
            _isConfigurated=NO;
        }//if eelse
    }else
        //if is an unknow command call the super method
        [super parseCommandResponseWithTimestamp:timestamp
                                        commandType:commandType
                                               data:data];
}//parseCommandResponseWithTimestamp

@end
