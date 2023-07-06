//
//  AudioRecorder.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

/// create a wave file and store the audio stream
public class AudioRecorder {

    /// date format that will be the file name
    private static let dateFormat = "yyyyMMdd_HHmmss"
    
    private static let fileNameFormat = "%@.wav"

    /// location of the created filed
    public let fileLocation: URL
    
    /// file pointer
    private var outFile: FileHandle
    
    /// thread used to serialize and put on background the write operation
    private let writeQueue = DispatchQueue(label: "WriteWavFile") //serial queue
    
    /// number of byte writed
    private var numberOfByteWrite: UInt32 = 0

    public init?(audioParam: AudioCodecSettings) {
        fileLocation = AudioRecorder.createFile()
        do {
            outFile = try FileHandle(forWritingTo: fileLocation)
        } catch (_) {
            return nil
        }
        
        writeQueue.async {
            self.writeWavHeader(audioParam)
            self.numberOfByteWrite = 0
        }
    }

    private static func getFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: Date()) //string from now
        return String(format: fileNameFormat, date)
    }

    private static func getDocumentDirectory() -> URL? {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }

    private static func createFile() -> URL {
        let fileManager = FileManager.default
        let docDir = getDocumentDirectory()
        let fileName = AudioRecorder.getFileName();
        let fileUrl = URL(fileURLWithPath: fileName, relativeTo: docDir)
        if !fileManager.fileExists(atPath: fileUrl.path) {
            fileManager.createFile(atPath: fileUrl.path, contents: nil)
        }

        return fileUrl
    }

    private func writeWavHeader(_ param: AudioCodecSettings) {
        outFile.writeStr("RIFF")                                                                    // chunk id
        outFile.writeUInt32(0)                                                                      // chunk size
        outFile.writeStr("WAVE")                                                                    // format
        outFile.writeStr("fmt ")                                                                    // subchunk 1 id
        outFile.writeUInt32(16)                                                                     // subchunk 1 size
        outFile.writeUInt16(1)                                                                      // audio format (1 = PCM)
        outFile.writeUInt16(UInt16(param.channels))                                                 // number of channels
        outFile.writeUInt32(UInt32(param.samplingFequency))                                         // sample rate
        let byteRate = UInt32(param.channels * param.samplingFequency * param.bytesPerSample)
        outFile.writeUInt32(byteRate)                                                               // byte rate
        outFile.writeUInt16(UInt16(param.channels * param.bytesPerSample))                          // block align
        outFile.writeUInt16(8 * UInt16(param.bytesPerSample))                                       // bits per sample
        outFile.writeStr("data")                                                                    // subchunk 2 id
        outFile.writeUInt32(0)                                                                      // subchunk 2 size
    }

    public func writeSample(sampleData: Data) {
        writeQueue.async {
            self.outFile.write(sampleData)
            self.numberOfByteWrite = self.numberOfByteWrite + UInt32(sampleData.count)
        }
    }

    public func stopRecord() {
        writeQueue.sync {
            self.outFile.seek(toFileOffset: 4)
            self.outFile.writeUInt32(36 + numberOfByteWrite)
            self.outFile.seek(toFileOffset: 40)
            self.outFile.writeUInt32(numberOfByteWrite)
            self.outFile.closeFile()
        }//sync
    }

}

// MARK: - extend the FileHandle to write directy some complex type
extension FileHandle {

    
    /// write a string
    ///
    /// - Parameter val: string to write, it will be econded as utf8 string
    public func writeStr(_ val: String) {
        let data = val.data(using: .utf8)
        if let d = data {
            write(d)
        }
    }

    /// write a uint32 value
    ///
    /// - Parameter val: value to write, it will be writed with little endianes
    public func writeUInt32(_ val: UInt32) {
        var temp = val
        let data = Data(bytes: &temp, count: 4)
        write(data)
    }

    /// write a int16 value
    ///
    /// - Parameter val: value to write, it will be writed as little endian
    public func writeUInt16(_ val: UInt16) {
        var temp = val
        let data = Data(bytes: &temp, count: 2)
        write(data)
    }
}
