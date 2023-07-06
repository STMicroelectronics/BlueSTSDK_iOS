//
//  DebugConsole+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

extension DebugConsole {
    internal static let dataChunkSize = 20

    /**
     * write the string into the stdin char, if the message is longer than 20byte,
     * it is splitted in multiple write that are done without waiting an answer.
    */
    func writeWithoutQueue(_ message: String){
        if let data = DebugConsole.stringToData(message) {
            var endOffset = min(DebugConsole.dataChunkSize, data.count)
            var startOffset = 0

            while (startOffset < endOffset) {
                writeFast(data: data[startOffset..<endOffset])
                startOffset = endOffset
                endOffset = min(endOffset + DebugConsole.dataChunkSize, data.count)
            }
        }
    }

    static func stringToData(_ text: String) -> Data? {
        return text.data(using: .isoLatin1)?.nullTerminated
    }

    static func dataToString(_ data: Data) -> String? {
        return String(bytes: data, encoding: .isoLatin1)
    }

}
