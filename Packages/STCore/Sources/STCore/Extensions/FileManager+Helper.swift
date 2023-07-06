//
//  FileManager+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension FileManager {
    var logFolderUrl: URL? {
        let logFolderUrl = appSupportFolder.appendingPathComponent("log")
        return createFolder(at: logFolderUrl)
    }

    var documentFolder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }

    var appSupportFolder: URL {

        let bundleIdentifier = Bundle.main.bundleIdentifier!

        let appSupportUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(bundleIdentifier)

        return createFolder(at: appSupportUrl)
    }

    @discardableResult
    func createLogFile(with name: String) -> URL? {

        guard let url = logFolderUrl?.appendingPathComponent(name) else { return nil }

        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        if FileManager.default.createFile(atPath: url.path,
                                          contents: nil,
                                          attributes: nil) {
            return url
        } else {
            return nil
        }
    }

    @discardableResult
    func createFolder(at url: URL) -> URL {
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        do {
            try FileManager.default.createDirectory(atPath: url.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            return url
        } catch {
            fatalError()
        }
    }
}
