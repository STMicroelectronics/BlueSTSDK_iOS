//
//  ExtraExampleFlow.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

// MARK: - ExtraExamplesFlowElement
public struct ExtraExampleFlow: Codable {
    public let model: String
    public let examplesFlow: [String]

    enum CodingKeys: String, CodingKey {
        case model
        case examplesFlow = "examples_flow"
    }
}
