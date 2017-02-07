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

#ifndef BlueSTSDK_BleAdvertiseParser_h
#define BlueSTSDK_BleAdvertiseParser_h

#import "BlueSTSDKBleNodeDefines.h"
#import "../BlueSTSDKNode.h"

/**
 *  Class that parse the ble advertise package
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKBleAdvertiseParser : NSObject

/**
 *  board name
 */
@property (readonly) NSString *name;

/**
 *  version of the protocol
 */
@property (readonly) unsigned char protocolVersion;
/**
 *  node id, tell the node type
 */
@property (readonly) unsigned char nodeId;

/**
 *  bit mask that tell what feature are available in the node
 */
@property (readonly) featureMask_t featureMap;

/**
 *  tell the tx power used by the node, in mdb
 */
@property (readonly) NSNumber* txPower;

/**
 *  tell the board type
 */
@property (readonly) BlueSTSDKNodeType nodeType;

/**
 *  address, can be nil if not present in the advertise
 */
@property (readonly) NSString *address;

/**
 * true if the board is in sleeping state
 */
@property (readonly) BOOL isSleeping;

/**
 * true if the board has some special extension
 */
@property (readonly) BOOL hasExtension;


/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with 
 * the BlueST protocol
 */
+(instancetype)advertiseParserWithAdvertise:(NSDictionary *)advertisementData;

/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with the
 * BlueST protocol
 */
-(instancetype)initWithAdvertise:(NSDictionary*)advertisementData;


@end

#endif
