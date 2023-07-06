//
//  FFTDataTransporter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class FFTDataTransporter {
    var sampleData: FFTAmplitudeData?
    
    public func decapsulate(data: Data, offset: Int) -> FFTAmplitudeData? {
        
        var sampleData: FFTAmplitudeData? = nil
        
        if self.sampleData == nil {
            self.sampleData = FFTAmplitudeData(with: data, offset: offset)
            sampleData = self.sampleData
        } else {
            self.sampleData?.append(data)
            sampleData = self.sampleData
            if sampleData?.isCompleted ?? false {
                reset()
            }
        }
        
        return sampleData
    }
    
    public func reset() {
        sampleData = nil
    }
}
