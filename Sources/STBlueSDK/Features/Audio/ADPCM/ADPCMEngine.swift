//
//  ADPCMEngine.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class ADPCMEngine {
    
    private static let stepSizeTable: [Int16] = [7,8,9,10,11,12,13,14,16,17,
                                                 19,21,23,25,28,31,34,37,41,45,
                                                 50,55,60,66,73,80,88,97,107,118,
                                                 130,143,157,173,190,209,230,253,279,307,
                                                 337,371,408,449,494,544,598,658,724,796,
                                                 876,963,1060,1166,1282,1411,1552,1707,1878,2066,
                                                 2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,
                                                 5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,
                                                 15289,16818,18500,20350,22385,24623,27086,29794,32767]
    
    private static let indexTable: [Int8] = [-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8]
    
    private var index: Int16 = 0
    private var predictedSample: Int32 = 0
    
    func decode(code: Int8, syncManager: ADPCMCodecManager) -> Int16 {
        var step: Int16
        var diffq: Int32
        
        if syncManager.intraFlag {
            predictedSample = syncManager.adpcmPredictedSampleIn
            index = syncManager.adpcmIndexIn
            syncManager.reinit()
//            STBlueSDK.log(text: "SET predicted sample: \(predictedSample) - index: \(index)")
        }
        
//        STBlueSDK.log(text: "USE Predicted sample: \(predictedSample) - index: \(index)")
        
        step = Self.stepSizeTable[Int(index)]
        
        /* 2. inverse code into diff */
        diffq = Int32(step >> 3)
        if (code & 4) != 0 {
            diffq += Int32(step)
        }
        
        if (code & 2) != 0 {
            diffq += Int32(step >> 1)
        }
        
        if (code & 1) != 0 {
            diffq += Int32(step >> 2)
        }
        
        /* 3. add diff to predicted sample*/
        if (code & 8) != 0 {
            predictedSample -= diffq
        } else {
            predictedSample += diffq
        }
        
        /* check for overflow*/
        if predictedSample > 32767 {
            predictedSample = 32767
        } else if predictedSample < -32768 {
            predictedSample = -32768
        }
        
        /* 4. find new quantizer step size */
        index += Int16(Self.indexTable[Int(code)])
        /* check for overflow*/
        if (index < 0) {
            index = 0
        }
        
        if (index > 88) {
            index = 88
        }
        
        /* 5. save predict sample and index for next iteration */
        /* done! static variables */
        
        /* 6. return new speech sample*/
        return Int16(predictedSample)
    }
    
}
