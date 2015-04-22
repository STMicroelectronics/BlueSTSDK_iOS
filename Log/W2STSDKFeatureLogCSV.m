//
//  W2STSDKFeatureLogCSV.m
//  W2STApp
//
//  Created by Giovanni Visentini on 22/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureLogCSV.h"

#import "../Features/W2STSDKFeatureField.h"

@implementation W2STSDKFeatureLogCSV{
    NSMutableDictionary *mCacheFileHandler;
}


-(id)init{
    self = [super init];
    mCacheFileHandler = [[NSMutableDictionary alloc] init];
    return self;
}

-(void) printHeader:(NSFileHandle*)out feature:(W2STSDKFeature*)f{
    NSArray *fields = [f getFieldsDesc];
    NSMutableString *line = [NSMutableString stringWithString:@"NodeName,RawData,"];
    for (W2STSDKFeatureField *field in fields){
        [line appendString:field.name];
        [line appendString:@","];
    }
    [line appendString:@"\n"];
    
    [out writeData: [line dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void) storeBlobData:(NSFileHandle*)out data:(NSData*)data{
    NSMutableString *temp = [NSMutableString string];
    [data enumerateByteRangesUsingBlock:^(const void *bytes,
                                          NSRange byteRange,
                                          BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [temp appendFormat:@"%02X", ((uint8_t*)bytes)[i]];
        }
    }];
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void) storeFeatureData:(NSFileHandle*)out data:(NSArray*)data{
    NSMutableString *temp = [NSMutableString string];
    for(NSNumber *n in data){
        [temp appendFormat:@"%@,",n];
    }
    [temp appendString:@"\n"];
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}

-(NSURL*) getDumpFileDirectoryUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(NSFileHandle*) openDumpFileForFeature:(W2STSDKFeature*)feature{
    NSFileHandle *temp = [mCacheFileHandler valueForKey:feature.name];
    if(temp!=nil)
        return temp;
    //else
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [self getDumpFileDirectoryUrl];
    NSString *fileName = [NSString stringWithFormat:@"%@.csv",feature.name ];
    NSURL *fileUrl = [NSURL URLWithString:fileName relativeToURL:documentsDirectory];

    if(![fileManager fileExistsAtPath:fileUrl.path]){
        [fileManager createFileAtPath:fileUrl.path contents:nil attributes:nil];
    }
    
    NSError *error = [[NSError alloc]init];
    temp = [NSFileHandle fileHandleForWritingToURL:fileUrl error:&error];
    [self printHeader:temp feature:feature];
    [mCacheFileHandler setValue:temp forKey:feature.name];
    return temp;
}

- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw data:(NSArray*)data{
    static char coma=',';
    @synchronized(self){
        NSFileHandle *file = [self openDumpFileForFeature:feature];

        [file writeData: [feature.parentNode.name dataUsingEncoding:NSUTF8StringEncoding]];
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        if(raw!=nil){
            [self storeBlobData:file data:raw];
        }
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        [self storeFeatureData:file data:data];
    }
}

-(void) closeFiles{
    NSEnumerator *enumerator = [mCacheFileHandler objectEnumerator];
    NSFileHandle *f;
    while ((f = [enumerator nextObject])) {
        [f closeFile];
    }
}


- (void)clean{
    
}
@end
