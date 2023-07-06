//
//  Array+PnpLContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Array where Element == PnpLContent {
    func element(with schema: String?) -> PnpLContent? {

        for content in self {
            switch content {
            case .primitiveProperty(let value):
                if value.id == schema {
                    return content
                }
            case .property(let value):
                if value.id == schema {
                    return content
                }
                //            case primitiveProperty(PnpLPrimitiveContent)
//            case enumerative(PnpLEnumerativeContent)
//            case object(PnpLObjectContent)
//            case command(PnpLCommandContent)
//            case commandPayload(PnpLCommandPayloadContent)
//            case unknown(PnpLUnknownContent)
            default:
                continue
            }
        }

        return nil
    }
}
