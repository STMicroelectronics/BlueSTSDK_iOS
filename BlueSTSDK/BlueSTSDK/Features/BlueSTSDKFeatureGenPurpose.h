//
//  BlueSTSDKFeatureGenPurpose.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 25/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <BlueSTSDK/BlueSTSDK.h>

/**
 * this is a special feature where the data are not parsed, since the format is 
 * unknow
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureGenPurpose : BlueSTSDKFeature

/**
 *  characteristic that update this feature
 */
@property(readonly,weak) CBCharacteristic* characteristics;

/**
 *  extract the array of byte transmitted by the feature
 *
 *  @param data feature sample
 *
 *  @return array of byte that are send by the feature
 */
+(NSData*) getRawData:(BlueSTSDKFeatureSample*)data;

/**
 *  initialize a general puprpose feature
 *
 *  @param node node that will update the data
 *  @param c    characteristics that will update the data
 *
 *  @return a genaral purpose feature initialize with the node and hte characteristics
 */
-(instancetype)initWhitNode:(BlueSTSDKNode *)node
            characteristics:(CBCharacteristic*)c;



@end
