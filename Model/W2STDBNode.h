//
//  W2STDBNode.h
//  W2STApp
//
//  Created by Antonino Raucea on 10/10/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class W2STDBSession;

@interface W2STDBNode : NSManagedObject

@property (nonatomic, retain) NSString * boardName;
@property (nonatomic, retain) NSNumber * feature;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * countSamplesMotion;
@property (nonatomic, retain) NSNumber * countSamplesEnvironment;
@property (nonatomic, retain) NSNumber * countSamplesAHRS;
@property (nonatomic, retain) W2STDBSession *session;

@end
