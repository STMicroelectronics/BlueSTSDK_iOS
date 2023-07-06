//
//  AudioPlayer.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import AVFoundation

/**
 * Audio callback called when an audio buffer can be reused
 * userData: pointer to our SyncQueue with the buffer to reproduce
 * queue: audio queue where the buffer will be played
 * buffer: audio buffer that must be filled
 */
fileprivate func audioCallback(usedData: UnsafeMutableRawPointer?,
                               queue: AudioQueueRef,
                               buffer: AudioQueueBufferRef) {
    
    // SampleQueue *ptr = (SampleQueue*) userData
    let sampleQueuePtr = usedData?.assumingMemoryBound(to: BlueVoiceSyncQueue.self)
    //NSData* data = sampleQueuePtr->pop();
    let data = sampleQueuePtr?.pointee.pop()
    //uint8* temp = (uint8*) buffer->mAudioData
    let temp = buffer.pointee.mAudioData.assumingMemoryBound(to: UInt8.self)
    
    //memcpy(temp,data)
    data?.copyBytes(to: temp, count: Int(buffer.pointee.mAudioDataByteSize))
    
    AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
}

public class AudioPlayer {
    
    private static let numberOfBuffers = 9
    
    private var audioFormat: AudioStreamBasicDescription
    
    //audio queue where play the sample
    private var queue: AudioQueueRef?
    //quueue of audio buffer to play
    private var buffers: [AudioQueueBufferRef?] = Array(repeating: nil, count: numberOfBuffers)
    //synchronized queue used to store the audio sample from the node
    // when an audio buffer is free it will be filled with sample from this object
    private var syncAudioQueue: BlueVoiceSyncQueue
    
    private var isMute: Bool = false
    
    private var isPlayBackStart = false
    
    public var mute: Bool = false {
        didSet {
            if mute {
                AudioQueueSetParameter(queue!, kAudioQueueParam_Volume, 0.0)
            } else {
                AudioQueueSetParameter(queue!, kAudioQueueParam_Volume, 1.0)
            }
        }
    }
    
    public init(_ param: AudioCodecSettings) {
        //https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CoreAudioDataTypesRef/#//apple_ref/c/tdef/AudioStreamBasicDescription
        audioFormat = AudioStreamBasicDescription(
            mSampleRate: Float64(param.samplingFequency),
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger,
            mBytesPerPacket: UInt32(param.bytesPerSample * param.channels),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(param.bytesPerSample * param.channels),
            mChannelsPerFrame: UInt32(param.channels),
            mBitsPerChannel: UInt32(8 * param.bytesPerSample),
            mReserved: 0)
        syncAudioQueue = BlueVoiceSyncQueue()
        
        //create the audio queue
        AudioQueueNewOutput(&audioFormat, audioCallback, &syncAudioQueue, nil, nil, 0, &queue)
        //create the system audio buffer that will be filled with the data inside the mSyncAudioQueue
        let bufferSizeByte = param.samplePerBlock * Int(param.bytesPerSample)
        for i in 0..<AudioPlayer.numberOfBuffers {
            AudioQueueAllocateBuffer(queue!,
                                     UInt32(bufferSizeByte),
                                     &buffers[i])
            
            if let buffer = buffers[i] {
                buffer.pointee.mAudioDataByteSize = UInt32(bufferSizeByte)
                memset(buffer.pointee.mAudioData, 0, bufferSizeByte)
                AudioQueueEnqueueBuffer(queue!, buffer, 0, nil)
            }
        }
        //start plaing the audio
    }
    
    public func playSample(sample: Data) {
        if !isPlayBackStart {
            AudioQueueStart(queue!, nil)
            isPlayBackStart = true
        }
        
        syncAudioQueue.push(newData: sample)
    }
    
    /// free the audio initialized audio queues
    deinit {
        AudioQueueStop(queue!, true)
        buffers.forEach { buff in
            if let buffer = buff {
                AudioQueueFreeBuffer(queue!, buffer)
            }
        }
    }
}
