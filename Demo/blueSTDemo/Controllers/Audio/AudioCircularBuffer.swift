//
//  AudioCircularBuffer.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

/// Circular Buffer that manage audio samples
public class AudioCircularBuffer {
    
    /// sample type
    public typealias Sample = Int16
    /// sample type after scaling
    public typealias ScaleSample = CGFloat
    /// type to use to compute the signal energy
    private typealias SquareSample = Double
    
    /// all sample will be scaled by this value before store it
    private let scaleFactor: ScaleSample
    
    /// array that will contain all the sample
    private var data: [ScaleSample]
    
    /// position where store the next value
    private var nextIndex = 0
    
    /// sum of the square of all the value in the circular buffer
    private var sumSquare: SquareSample = 0
    
    /// size of the circular buffer
    public var count: UInt {
        UInt(data.count)
    }
    
    /// create a circular buffer
    ///
    /// - Parameters:
    ///   - size: size of th buffer
    ///   - scale: scale factor to apply to all the sample store in the buffer
    public init(size: Int, scale: ScaleSample) {
        scaleFactor = scale
        data = Array<ScaleSample>(repeating: ScaleSample(0), count: size)
    }
    
    /// add a value into the array
    ///
    /// - Parameter val: value to add
    public func append(_ value: Sample) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let scaleVal = ScaleSample(value) * scaleFactor
        //we have to remove a element
        if nextIndex >= data.count {
            let idx = nextIndex % data.count
            let oldVal = data[idx]
            data[idx] = scaleVal
            //update square sum
            sumSquare -= SquareSample(oldVal * oldVal)
            sumSquare += SquareSample(scaleVal * scaleVal)
            nextIndex += 1
        } else {
            sumSquare += SquareSample(scaleVal * scaleVal)
            data[nextIndex] = scaleVal
            nextIndex += 1
        }
    }
    
    public func dumpTo(_ snapshot: inout [ScaleSample]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let snapshotLenght = min(snapshot.count, data.count)
        for i in 0...snapshotLenght - 1 {
            let idx = (nextIndex + i) % data.count
            snapshot[i] = data[idx]
        }
    }
}
