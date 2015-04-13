//
//  W2STSDKFeatureAutoConfigurable.h
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"
@protocol W2STSDKFeatureAutoConfigurableDelegate;

@interface W2STSDKFeatureAutoConfigurable : W2STSDKFeature

@property(readonly) BOOL isConfigurated;

-(BOOL) startAutoConfiguration;
-(BOOL) requestAutoConfigurationStatus;
-(BOOL) stopAutoConfiguration;

-(void) addFeatureConfigurationDelegate:(id<W2STSDKFeatureAutoConfigurableDelegate>)delegate;
-(void) removeFeatureConfigurationDelegate:(id<W2STSDKFeatureAutoConfigurableDelegate>)delegate;


//protected method
-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;
-(void) commandResponceReveivedWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data;

@end

@protocol  W2STSDKFeatureAutoConfigurableDelegate <NSObject>
@optional
- (void)didAutoConfigurationStart:(W2STSDKFeatureAutoConfigurable *)feature;
@optional
- (void)didAutoConfigurationChange:(W2STSDKFeatureAutoConfigurable *)feature status:(int32_t)status;
@optional
- (void)didConfigurationFinished:(W2STSDKFeatureAutoConfigurable *)feature status:(int32_t)status;
@end