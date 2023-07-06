//
//  UnwrapTimeStamp.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class UnwrapTimeStamp {

    let nearToEndTh = ((1 << 16) - 100)

    /** number of time that the ts has reset, the timestamp is reseted when we receive a ts with
     * a  value > 65435 and than a package with a smaller value */
    private var numberOfReset: UInt32 = 0;

    /** last raw ts received from the board, it is a number between 0 and 2^16-1 */
    private var lastRawTs: UInt32 = 0;

}

extension UnwrapTimeStamp {

    func current(with data: Data) -> UInt64 {
        if data.count >= 2 {
            let timestamp16 = data.extractUInt16(fromOffset: 0)
            return unwrap(ts: timestamp16)
        } else {
            return getNext()
        }
    }

}

internal extension UnwrapTimeStamp {
    func getNext() -> UInt64 {
        return unwrap(ts: UInt16(lastRawTs) + 1)
    }

    func unwrap(ts: UInt16) -> UInt64 {
        objc_sync_enter(self)

        defer { objc_sync_exit(self) }

        if (lastRawTs > (nearToEndTh) && lastRawTs > ts) {
            numberOfReset += 1
        }

        lastRawTs = UInt32(ts)

        return UInt64(numberOfReset) * (1 << 16) + UInt64(ts)
    }
}
