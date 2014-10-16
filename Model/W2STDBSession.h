//
//  W2STDBSession.h
//  W2STApp
//
//  Created by Antonino Raucea on 10/10/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class W2STDBNode;

@interface W2STDBSession : NSManagedObject

@property (nonatomic, retain) NSDate * dateEnd;
@property (nonatomic, retain) NSDate * dateStart;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * running;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface W2STDBSession (CoreDataGeneratedAccessors)

- (void)addNodesObject:(W2STDBNode *)value;
- (void)removeNodesObject:(W2STDBNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
