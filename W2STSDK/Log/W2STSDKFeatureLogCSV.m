//
//  W2STSDKFeatureLogCSV.m
//  W2STApp
//
//  Created by Giovanni Visentini on 22/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureLogCSV.h"
#import "W2STSDKNode.h"
#import "../Features/W2STSDKFeatureField.h"

@implementation W2STSDKFeatureLogCSV{
    /**
     *  dictionary where we store the pair W2STSDKFeature/NSFileHandle for be able
     * to use the same log with multiple feature
     */
    NSMutableDictionary *mCacheFileHandler;
}

-(id)init{
    self = [super init];
    mCacheFileHandler = [[NSMutableDictionary alloc] init];
    return self;
}

/**
 *  print the csv header
 *
 *  @param out handle where write the data
 *  @param f   feature that we will log in the file
 */
-(void) printHeader:(NSFileHandle*)out feature:(W2STSDKFeature*)f{
    NSArray *fields = [f getFieldsDesc];
    NSMutableString *line = [NSMutableString stringWithString:@"DeviceName,Timestamp,RawData,"];
    for (W2STSDKFeatureField *field in fields){
        [line appendString:field.name];
        [line appendString:@","];
    }
    [line appendString:@"\n"];
    
    [out writeData: [line dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 *  print an array of byte in a exadecimal format
 *
 *  @param out  file where write the data
 *  @param data array of byte to write
 */
-(void) storeBlobData:(NSFileHandle*)out data:(NSData*)data{
    NSMutableString *temp = [NSMutableString string];
    //for each block in the data append the exadecimal value to the string
    [data enumerateByteRangesUsingBlock:^(const void *bytes,
                                          NSRange byteRange,
                                          BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [temp appendFormat:@"%02X", ((uint8_t*)bytes)[i]];
        }
    }];
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 *  print the data exported by the feature
 *
 *  @param out  file where write the data
 *  @param data array of NSNumber to print
 */
-(void) storeFeatureData:(NSFileHandle*)out data:(NSArray*)data{
    NSMutableString *temp = [NSMutableString string];
    for(NSNumber *n in data){
        [temp appendFormat:@"%@,",n];
    }
    [temp appendString:@"\n"];
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 *  return the position of the app document directory
 *
 *  @return position of the document directory
 */
+(NSURL*) getDumpFileDirectoryUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/**
 *  create/open a new file or retrive the already opened one to be used for log 
 *  the feature data
 *
 *  @param feature feature that we will log in the file
 *
 *  @return file where log the data
 */
-(NSFileHandle*) openDumpFileForFeature:(W2STSDKFeature*)feature{
    NSFileHandle *temp = [mCacheFileHandler valueForKey:feature.name];
    if(temp!=nil)
        return temp;
    //else
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [W2STSDKFeatureLogCSV getDumpFileDirectoryUrl];
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

-(void) storeTimeStamp:(uint32_t)timestamp{
    
}

- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw sample:(W2STSDKFeatureSample *)sample{
    static const char coma=',';
 
    NSFileHandle *file = [self openDumpFileForFeature:feature];
    @synchronized(file){
        [file writeData: [feature.parentNode.name dataUsingEncoding:NSUTF8StringEncoding]];
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        NSString *timeStampStr = [NSString stringWithFormat:@"%d",sample.timestamp];
        [file writeData: [timeStampStr dataUsingEncoding:NSUTF8StringEncoding]];
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        if(raw!=nil){
            [self storeBlobData:file data:raw];
        }
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        [self storeFeatureData:file data:sample.data];
    }
}

-(void) closeFiles{
    NSEnumerator *enumerator = [mCacheFileHandler objectEnumerator];
    NSFileHandle *f;
    while ((f = [enumerator nextObject])) {
        [f closeFile];
    }
    [mCacheFileHandler removeAllObjects];
}

+(NSArray*) getLogFiles{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [W2STSDKFeatureLogCSV getDumpFileDirectoryUrl];
    NSArray *files = [fileManager contentsOfDirectoryAtURL:documentsDirectory
                               includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                  options:(NSDirectoryEnumerationSkipsHiddenFiles |
                                                          NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                                    error:&error];
    NSIndexSet *indexes = [files indexesOfObjectsPassingTest:
                           ^BOOL (id obj, NSUInteger i, BOOL *stop) {
                               NSURL *url = (NSURL*)obj;
                               return [url.pathExtension isEqualToString:@"csv"];
                           }];
    return [files objectsAtIndexes:indexes];
    
}

+(void) removeLogFiles{
    NSArray *files = [W2STSDKFeatureLogCSV getLogFiles];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for(NSURL *file in files){
        [fileManager removeItemAtURL:file error:&error];
        if(error)
            NSLog(@"Error Removing the file %@ : %@",file.path,error.localizedDescription);
    }//for
    
}
@end
