//
//  W2STDBSampleMotion.h
//  W2STApp
//
//  Created by Antonino Raucea on 10/10/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class W2STDBNode, W2STDBSession;

@interface W2STDBSampleMotion : NSManagedObject

@property (nonatomic, retain) NSNumber * acc_x;
@property (nonatomic, retain) NSNumber * acc_y;
@property (nonatomic, retain) NSNumber * acc_z;
@property (nonatomic, retain) NSNumber * gyr_x;
@property (nonatomic, retain) NSNumber * gyr_y;
@property (nonatomic, retain) NSNumber * gyr_z;
@property (nonatomic, retain) NSNumber * mag_x;
@property (nonatomic, retain) NSNumber * mag_y;
@property (nonatomic, retain) NSNumber * mag_z;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) W2STDBNode *node;
@property (nonatomic, retain) W2STDBSession *session;

@end
