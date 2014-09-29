//
//  W2STSDKDataLog.m
//  W2STApp
//
//  Created by Antonino Raucea on 09/09/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDataLog.h"

@implementation W2STSDKDataLog


- (id)init {
    self = [super init];
    [self createNewSessionRunning:YES save:YES];
    return self;
}

- (BOOL)isRunning {
    return [_session.running boolValue];
}
- (W2STDBSession *)createNewSessionRunning:(BOOL)running save:(BOOL)save {
    //log: session init
    _dataManager = [W2STDBManager sharedInstance];
    _context = [_dataManager mainObjectContext];
    _session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:_context];
    
    assert(_dataManager && _context && _session);
    
    //log: session insert time stamp
    NSDateFormatter *dateFormatterName = [[NSDateFormatter alloc] init];
    [dateFormatterName setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *dateFormatterDescr = [[NSDateFormatter alloc] init];
    [dateFormatterDescr setDateStyle:NSDateFormatterLongStyle];
    [dateFormatterDescr setTimeStyle:NSDateFormatterLongStyle];
    
    //initialize the fields
    _session.date_start = [NSDate date];
    _session.date_end = [NSDate date]; //if the session is open this is a dummy value
    _session.name = [dateFormatterName stringFromDate:_session.date_start];
    _session.descr = [dateFormatterDescr stringFromDate:_session.date_start];
    _session.running = [NSNumber numberWithBool:running];
    
    //save data
    if (save) {
        [_dataManager save];
    }
    return _session;
}

- (void)closeCurrentSessionSave:(BOOL)save {
   assert(_dataManager && _context && _session);
    if ([self isRunning]) {
        _session.running = [NSNumber numberWithBool:NO];
        _session.date_end = [NSDate date];

        //save data
        if (save) {
            [_dataManager save];
        }
    }
}
- (bool)addNode:(W2STSDKNode *)node save:(BOOL)save {
   assert(_dataManager && _context && _session && node);
    if (![self isRunning]) {
        return NO;
    }
    
    W2STDBNode *db_node = nil;
    BOOL ret = NO;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Node"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(identifier = %@) && (session = %@)", [node UUIDGetString], _session]];
    //[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
    NSArray *res = [_context executeFetchRequest:fetchRequest error:NULL];
    assert(res.count <= 1);
    if (res.count == 0) {
        db_node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:_context];
        db_node.identifier = [node UUIDGetString];
        ret = YES;    }
    else {
        //update fields
        db_node = res[0];
    }
    db_node.name = node.name;
    db_node.boardName = node.nameBoardGetString;
    db_node.feature = [NSNumber numberWithInt:node.featureByte];
    node.dbNode = db_node; //store db_node inside node item
    
    //log: add node to session
    if (![_session.nodes containsObject:db_node]) {
        [_session addNodesObject:db_node];
    }
    
    //log: add session to node
    db_node.session = _session;
    
    //save data
    if (save) {
        [_dataManager save];
    }
    return ret;
}

- (bool)addRawDataWithGroup:(NSInteger)group data:(NSData *)data node:(W2STSDKNode *)node save:(BOOL)save {
    return YES;
    assert(_dataManager && _context && _session && data);
    if (![self isRunning]) {
        return NO;
    }
    
    const unsigned char *buffer = (const unsigned char *)[data bytes];
    //int8_t size = (int8_t)data.length;
    uint16_t time = (uint16_t)(*((uint16_t *)buffer));
    uint16_t pos = 0;
    
    uint8_t hw_map = node.hwFeatureByte;
    uint8_t sw_map = node.swFeatureByte;

    switch((W2STSDKNodeFrameGroup)group) {
        case W2STSDKNodeFrameGroupRaw:
        {
            W2STDBRawDataMotion *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataMotion" inManagedObjectContext:_context];
            
            db_item.time = time; pos+=2; //save time
            if (hw_map & (W2STSDKNodeFeatureHWAcce & 0xFF)) {
                db_item.acc_x = (uint16_t)(*((uint16_t *)&buffer[pos]));
                db_item.acc_y = (uint16_t)(*((uint16_t *)&buffer[pos+2]));
                db_item.acc_z = (uint16_t)(*((uint16_t *)&buffer[pos+4]));
                pos += 6;
            }
            if (hw_map & (W2STSDKNodeFeatureHWGyro & 0xFF)) {
                db_item.gyr_x = (uint16_t)(*((uint16_t *)&buffer[pos]));
                db_item.gyr_y = (uint16_t)(*((uint16_t *)&buffer[pos]));
                db_item.gyr_z = (uint16_t)(*((uint16_t *)&buffer[pos]));
                pos += 6;
            }
            if (hw_map & (W2STSDKNodeFeatureHWMagn & 0xFF)) {
                db_item.mag_x = (uint16_t)(*((uint16_t *)&buffer[pos]));
                db_item.mag_y = (uint16_t)(*((uint16_t *)&buffer[pos]));
                db_item.mag_z = (uint16_t)(*((uint16_t *)&buffer[pos]));
                pos += 6;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataMotionsObject:db_item];
            
        }
            break;
        case W2STSDKNodeFrameGroupEnvironment:
        {
            W2STDBRawDataEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataEnvironment" inManagedObjectContext:_context];
            
            db_item.time = time; pos+=2; //save time
            if (hw_map & (W2STSDKNodeFeatureHWPres & 0xFF)) {
                db_item.pressure = (uint32_t)(*((uint32_t *)&buffer[pos])); pos += 4;
            }
            if (hw_map & (W2STSDKNodeFeatureHWTemp & 0xFF)) {
                db_item.temperature = (uint16_t)(*((uint16_t *)&buffer[pos])); pos += 2;
            }
            if (hw_map & (W2STSDKNodeFeatureHWHumd & 0xFF)) {
                db_item.humidity = (uint16_t)(*((uint16_t *)&buffer[pos])); pos += 2;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataEnvironmentsObject:db_item];
        }
            break;
        case W2STSDKNodeFrameGroupAHRS:
        {
            W2STDBRawDataAHRS *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataAHRS" inManagedObjectContext:_context];
            
            db_item.time = time; pos+=2; //save time
            if (sw_map & (W2STSDKNodeFeatureSWAHRS & 0xFF)) {
                db_item.qx = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qy = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qz = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qw = (uint32_t)(*((uint32_t *)&buffer[pos]));
                pos += 16;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataAHRSsObject:db_item];
       }
            break;
        default:
            break;
    }
    
    //save data
    if (save) {
        [_dataManager save];
    }

    return YES;
}

@end
