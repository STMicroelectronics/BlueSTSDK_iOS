/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "BlueSTSDKFeatureLogCSV.h"
#import "BlueSTSDKNode.h"
#import "../Features/BlueSTSDKFeatureField.h"

@implementation BlueSTSDKFeatureLogCSV{
    /**
     *  dictionary where we store the pair BlueSTSDKFeature/NSFileHandle for be able
     * to use the same log with multiple feature
     */
    NSMutableDictionary *mCacheFileHandler;
}

-(instancetype)init{
    self = [super init];
    mCacheFileHandler = [NSMutableDictionary dictionary];
    return self;
}

/**
 *  print the csv header: device name + time stamp + raw data + data type 
 * exported by the feature
 *
 *  @param out handle where write the data
 *  @param f   feature that we will log in the file
 */
-(void) printHeader:(NSFileHandle*)out feature:(BlueSTSDKFeature*)f{
    NSArray *fields = [f getFieldsDesc];
    NSMutableString *line = [NSMutableString stringWithString:@"DeviceName,Timestamp,RawData,"];
    for (BlueSTSDKFeatureField *field in fields){
        [line appendString:field.name];
        [line appendString:@","];
    }
    [line appendString:@"\n"];
    
    [out writeData: [line dataUsingEncoding:NSUTF8StringEncoding]];
}//printHeader

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
        }//for
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
    }//for
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
-(NSFileHandle*) openDumpFileForFeature:(BlueSTSDKFeature*)feature{
    //syncronize this function for be secure that we enter here one call at time,
    //for avoid ghost update duplicate entry ecc..
    @synchronized(mCacheFileHandler){
        NSFileHandle *temp = [mCacheFileHandler valueForKey:feature.name];
        if(temp!=nil)
            return temp;
        //else
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [BlueSTSDKFeatureLogCSV getDumpFileDirectoryUrl];
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
    }//syncronized
}

/**
 *  function called by the feature when it has new data, this function will store
 * all the data inside a file in a csv format
 *
 *  @param feature feature that is update
 *  @param raw     raw data unsed for update the feature, they can be nil
 *  @param sample  data extracted by the feature
 */
- (void)feature:(BlueSTSDKFeature *)feature rawData:(NSData*)raw sample:(BlueSTSDKFeatureSample *)sample{
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
        }//if
        [file writeData:[NSData dataWithBytes:&coma length:1]];
        [self storeFeatureData:file data:sample.data];
    }
}

-(void) closeFiles{
    @synchronized(mCacheFileHandler){
        NSEnumerator *enumerator = [mCacheFileHandler objectEnumerator];
        NSFileHandle *f;
        while ((f = [enumerator nextObject])) {
            [f closeFile];
        }//while
        [mCacheFileHandler removeAllObjects];
    }
}

+(NSArray*) getLogFiles{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [BlueSTSDKFeatureLogCSV getDumpFileDirectoryUrl];
    //get all the file in the directory
    NSArray *files = [fileManager contentsOfDirectoryAtURL:documentsDirectory
                               includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                  options:(NSDirectoryEnumerationSkipsHiddenFiles |
                                                          NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                                    error:&error];
    //filter the files and keep only the ones with extenstion csv
    NSIndexSet *indexes = [files indexesOfObjectsPassingTest:
                           ^BOOL (id obj, NSUInteger i, BOOL *stop) {
                               NSURL *url = (NSURL*)obj;
                               return [url.pathExtension isEqualToString:@"csv"];
                           }];
    return [files objectsAtIndexes:indexes];
    
}

+(void) removeLogFiles{
    NSArray *files = [BlueSTSDKFeatureLogCSV getLogFiles];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for(NSURL *file in files){
        [fileManager removeItemAtURL:file error:&error];
        if(error)
            NSLog(@"Error Removing the file %@ : %@",file.path,error.localizedDescription);
    }//for
    
}
@end
