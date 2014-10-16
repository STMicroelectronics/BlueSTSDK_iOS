//
//  W2STDBSampleAHRS.h
//  W2STApp
//
//  Created by Antonino Raucea on 10/10/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class W2STDBNode, W2STDBSession;

@interface W2STDBSampleAHRS : NSManagedObject

@property (nonatomic, retain) NSNumber * qw;
@property (nonatomic, retain) NSNumber * qx;
@property (nonatomic, retain) NSNumber * qy;
@property (nonatomic, retain) NSNumber * qz;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) W2STDBNode *node;
@property (nonatomic, retain) W2STDBSession *session;

@end
