/*******************************************************************************
 * COPYRIGHT(c) 2019 STMicroelectronics
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
import Foundation

//is pubblic and objc to be used inside the BlueSTSDKNode class
class BlueSTSDKAdvertiseInfo : NSObject, BleAdvertiseInfo{
    public let name:String?
    public let address:String?
    public let featureMap:UInt32
    public let deviceId:UInt8
    public let protocolVersion:UInt8
    public let boardType:BlueSTSDKNodeType
    public let isSleeping:Bool
    public let hasGeneralPurpose:Bool
    public let txPower:UInt8
    
    init(name: String?, address: String?, featureMap: UInt32, deviceId: UInt8, protocolVersion: UInt8,
               boardType: BlueSTSDKNodeType, isSleeping: Bool, hasGeneralPurpose: Bool, txPower: UInt8){
        self.name = name
        self.address = address
        self.featureMap = featureMap
        self.deviceId = deviceId
        self.protocolVersion = protocolVersion
        self.boardType = boardType
        self.isSleeping = isSleeping
        self.hasGeneralPurpose = hasGeneralPurpose
        self.txPower = txPower
        super.init()
    }
    
}
