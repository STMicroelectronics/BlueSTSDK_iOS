//
//  W2STDBSampleEnvironment.h
//  W2STApp
//
//  Created by Antonino Raucea on 10/10/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class W2STDBNode, W2STDBSession;

@interface W2STDBSampleEnvironment : NSManagedObject

@property (nonatomic, retain) NSNumber * humidity;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) W2STDBNode *node;
@property (nonatomic, retain) W2STDBSession *session;

@end
