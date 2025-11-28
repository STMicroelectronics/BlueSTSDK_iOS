//
//  RawPnPLStream.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI

public struct RawPnPLStream {
    let id: Int
    let streamName: String?
    var codeValues: [any KeyValue]?
    var parsedLabels: [RawPnPLEnumLabel]?
    var rawCustom: RawCustom?
}
