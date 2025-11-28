//
//  URLSession+Firmware.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public extension URLSession {

//    public func delete(fileName: String) {
//        let destinationUrl = FileManager.default.documentFolder.appendingPathComponent(fileName)
//
//        guard FileManager.default.fileExists(atPath: destinationUrl.path) else { return }
//        do {
//            try FileManager().removeItem(atPath: destinationUrl.path)
//            STBlueSDK.log(text: "File deleted successfully")
//        } catch let error {
//            STBlueSDK.log(text: "Error while deleting file: \(error.localizedDescription)")
//        }
//    }

//    func asset(with fileName: String) -> URL? {
//        let docsUrl = FileManager.default.documentFolder.app
//
//        let destinationUrl = docsUrl?.appendingPathComponent(fileName)
//        if let destinationUrl = destinationUrl {
//            if (FileManager().fileExists(atPath: destinationUrl.path)) {
//                STBlueSDK.log(text: "Error while deleting file: \(error.localizedDescription)")
//                print("DESTINATION PATH URL: \(destinationUrl)")
//                return destinationUrl
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }

    func downloadFirmware(_ firmware: Firmware,
                      completion: @escaping (Result<URL, STError>) -> Void) {
        downloadFile(with: firmware.url,
                     fileName: firmware.fileName,
                     completion: completion)
    }
    
    func directDownloadFirmware(_ firmware: Firmware,
                      completion: @escaping (Result<URL, STError>) -> Void) {
        directDownloadFile(with: firmware.url,
                     fileName: firmware.fileName,
                     completion: completion)
    }
}

internal extension URLSession {
    func downloadFile(with url: URL?,
                      fileName: String,
                      completion: @escaping (Result<URL, STError>) -> Void) {

        var destinationUrl = FileManager.default.documentFolder.appendingPathComponent(fileName)
        
        if fileName.contains("/") {
            destinationUrl = FileManager.default.documentFolder.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: ""))
        }

        guard let url = url else {
            STBlueSDK.log(text: "URL not valid")
            completion(.failure(STError.urlNotValid))
            return
        }

        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            STBlueSDK.log(text: "File already exists: \(destinationUrl.path)")
            completion(.success(destinationUrl))
        } else {
            let urlRequest = URLRequest(url: url)

            let dataTask = dataTask(with: urlRequest) { (data, response, error) in

                if let error = error {
                    STBlueSDK.log(text: "Request error: \(error.localizedDescription)")
                    completion(.failure(STError.server(error: error)))
                    return
                }

                guard let response = response as? HTTPURLResponse else { return }

                if response.statusCode == 200 {
                    guard let data = data else {
                        STBlueSDK.log(text: "File data not valid")
                        completion(.failure(STError.dataNotValid))
                        return
                    }
                    DispatchQueue.main.async {
                        do {
                            try data.write(to: destinationUrl,
                                           options: Data.WritingOptions.atomic)
                            STBlueSDK.log(text: "File download completed: \(destinationUrl.path)")
                            completion(.success(destinationUrl))
                        } catch let error {
                            STBlueSDK.log(text: "Error decoding: \(error.localizedDescription)")
                            completion(.failure(STError.server(error: error)))
                        }
                    }
                } else {
                    completion(.failure(STError.generic(text: "Corrupted file")))
                }
            }
            dataTask.resume()
        }
    }
    
    func directDownloadFile(with url: URL?,
                      fileName: String,
                      completion: @escaping (Result<URL, STError>) -> Void) {

        var destinationUrl = FileManager.default.documentFolder.appendingPathComponent(fileName)
        
        if fileName.contains("/") {
            destinationUrl = FileManager.default.documentFolder.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: ""))
        }

        guard let url = url else {
            STBlueSDK.log(text: "URL not valid")
            completion(.failure(STError.urlNotValid))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            if let url = urlRequest.url {
                if let newUrl = replacingWithBetaUrl(originalUrl: url) {
                    urlRequest.url = newUrl
                }
            }
        }

        let dataTask = dataTask(with: urlRequest) { (data, response, error) in

            if let error = error {
                STBlueSDK.log(text: "Request error: \(error.localizedDescription)")
                completion(.failure(STError.server(error: error)))
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else {
                    STBlueSDK.log(text: "File data not valid")
                    completion(.failure(STError.dataNotValid))
                    return
                }
                DispatchQueue.main.async {
                    do {
                        try data.write(to: destinationUrl,
                                       options: Data.WritingOptions.atomic)
                        STBlueSDK.log(text: "File download completed: \(destinationUrl.path)")
                        completion(.success(destinationUrl))
                    } catch let error {
                        STBlueSDK.log(text: "Error decoding: \(error.localizedDescription)")
                        completion(.failure(STError.server(error: error)))
                    }
                }
            } else {
                completion(.failure(STError.generic(text: "Corrupted file")))
            }
        }
        dataTask.resume()
    }
    
    private func replacingWithBetaUrl(originalUrl: URL) -> URL? {

        if var comps = URLComponents(url: originalUrl, resolvingAgainstBaseURL: false) {
            var segments = comps.path.split(separator: "/")

            if segments.first == "STMicroelectronics" {
                segments[0] = "SW-Platforms"
            }

            comps.path = "/" + segments.joined(separator: "/")

            if let updated = comps.url {
                return updated
            }
            
            return nil
        }
        
        return nil
        
    }
}
