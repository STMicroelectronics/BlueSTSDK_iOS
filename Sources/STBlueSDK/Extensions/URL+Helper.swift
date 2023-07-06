//
//  URL+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal extension URL {
    func readFileContent() -> Data? {
        let fileHandler = try? FileHandle(forReadingFrom: self)
        let data = fileHandler?.readDataToEndOfFile()
        fileHandler?.closeFile()
        return data
    }
}
