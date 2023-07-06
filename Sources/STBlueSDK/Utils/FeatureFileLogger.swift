//
//  FeatureFileLogger.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STCore

public class FeatureFileLogger {
    
    private let internalQueue = DispatchQueue(label: "[FeatureFileLogger: \(UUID().uuidString)]")
    private var cachedFileHandles: [String: FileHandle] = [String: FileHandle]()

    public var isEnabled: Bool = false
    var startLoggingDate: Date = Date()
    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
    }
}

private extension FeatureFileLogger {

    func logHeader(feature: Feature, fileHandle: FileHandle) {
        var line = "Logged started on: \(DateFormatter.seconds.string(from: startLoggingDate))"
        line += "\n"
        line += "Feature: \(feature.name)"

        line += "\n\n"
        line += "Date,HostTimestamp,NodeName"

        line += ",\(feature.logHeader)"

        guard let data = line.data(using: .utf8) else { return }

        fileHandle.write(data)
    }

    func log(feature: Feature, node: Node, fileHandle: FileHandle) {
        guard let notificationDate = feature.notificationDate else { return }
        var line = "\n\(DateFormatter.milliSeconds.string(from: notificationDate)),"

        line += "\(notificationDate.timeIntervalSince(startLoggingDate)),"
        line += "\(node.name ?? "n/a"),"
        line += "\(feature.logValue)"

        guard let data = line.data(using: .utf8) else { return }

        fileHandle.write(data)
    }
}

extension FeatureFileLogger: FeatureLogger {
    
    public var loggedFile: [URL] {
        guard let path = FileManager.default.logFolderUrl?.path else { return [] }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            
            return contents.compactMap {
                URL(fileURLWithPath: path).appendingPathComponent($0)
            }
            
        } catch {
            return []
        }
    }
    
    public func start() {
        isEnabled = true
        startLoggingDate = Date()
    }

    public func stop() {
        isEnabled = false
        
        internalQueue.sync { [weak self] in
            guard let self = self else { return }
            
            for fileHandler in self.cachedFileHandles.values {
                fileHandler.closeFile()
            }
            
            self.cachedFileHandles.removeAll()
        }
    }
    
    public func clear() {
        guard let folder = FileManager.default.logFolderUrl else { return }
        do {
            try FileManager.default.removeItem(at: folder)
        } catch {
            
        }
    }

    public func log(feature: Feature, node: Node) {
        if !isEnabled {
            return
        }

        internalQueue.sync { [weak self] in

            guard let self = self else { return }

            let name = feature.name
            
            if let fileHandle = cachedFileHandles[name] {
                self.log(feature: feature, node: node, fileHandle: fileHandle)
                return
            }

            let filename = "\(dateFormatter.string(from: startLoggingDate))_\(name)"
                .replacingOccurrences(of: " ", with: "_")

            guard let url = FileManager.default.createLogFile(with: filename),
                  let fileHandle = FileHandle(forWritingAtPath: url.path) else { return }

            cachedFileHandles[name] = fileHandle

            self.logHeader(feature: feature, fileHandle: fileHandle)
            self.log(feature: feature, node: node, fileHandle: fileHandle)
        }
    }
}
