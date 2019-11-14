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
import UIKit

public extension BlueSTSDKDebug{
    private static let DATA_CHUNK_SIZE = 20
    
    /**
     * write the string into the stdin char, if the message is longer than 20byte,
     * it is splitted in multiple write that are done without waiting an answer.
    */
    func writeWithoutQueue(_ msg:String){
        if let data = BlueSTSDKDebug.stringToData(msg){
            var endOffset = min(BlueSTSDKDebug.DATA_CHUNK_SIZE,data.count)
            var startOffset = 0
            while(startOffset<endOffset){
                self.writeMessageDataFast(data[startOffset..<endOffset])
                startOffset = endOffset
                endOffset = min(endOffset+BlueSTSDKDebug.DATA_CHUNK_SIZE,data.count)
            }
        }
        
    }
    
    @objc static func stringToData(_ str:String) -> Data?{
        return str.data(using: .isoLatin1)
    }
    
    @objc static func dataToString(_ data:Data) -> String?{
        return String(bytes: data, encoding: .isoLatin1)
    }
    
}
