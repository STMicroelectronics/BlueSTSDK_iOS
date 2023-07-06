//
//  URLSession+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public enum Environment: String {
    case prod = "STMicroelectronics"
    case dev = "SW-Platforms"
}

internal enum EndPoint {

    case catalogChecksum(env: Environment)
    case catalog(env: Environment)
    case dtmi(env: Environment, firmware: Firmware)

    var url: URL? {
        switch self {

        case .catalogChecksum(let env):
            return URL(string: "https://raw.githubusercontent.com/\(env.rawValue)/appconfig/main/bluestsdkv2/chksum.json")

        case .catalog(let env):
            if(env == .dev) {
                return URL(string: "https://raw.githubusercontent.com/\(env.rawValue)/appconfig/release/bluestsdkv2/catalog.json")
            } else {
                return URL(string: "https://raw.githubusercontent.com/\(env.rawValue)/appconfig/blesensor_\(STCore.appShortVersion)/bluestsdkv2/catalog.json")
            }

        case .dtmi(let env, let firmware):

            guard let dtmi = firmware.dtmi else { return nil }

            var dtmiUri = dtmi
            dtmiUri = dtmiUri.replacingOccurrences(of: ":", with: "/")
            dtmiUri = dtmiUri.replacingOccurrences(of: ";", with: "-")

            if dtmi.contains("dtmi:stmicroelectronics") {
                return URL(string: "https://devicemodels.azure.com/" + dtmiUri + ".expanded.json")
            } else {
                return URL(string: "https://raw.githubusercontent.com/\(env.rawValue)/appconfig/release/" + dtmiUri + ".expanded.json")
            }
        }
    }
}

internal extension URLSession {

    func getCatalog(with env: Environment, completion: @escaping (Result<Catalog, STError>) -> Void) {
        performRequest(on: .catalog(env: env), completion: completion)
    }

    func getDtmi(with env: Environment, firmware: Firmware, completion: @escaping (Result<[PnpLContent], STError>) -> Void) {
        performRequest(on: .dtmi(env: env, firmware: firmware), completion: completion)
    }

    func getCatalogChecksum(with env: Environment, completion: @escaping (Result<Checksum, STError>) -> Void) {
        performRequest(on: .catalogChecksum(env: env), completion: completion)
    }

    func performRequest<T: Decodable>(on endPoint: EndPoint, completion: @escaping (Result<T, STError>) -> Void) {

        guard let url = endPoint.url else {
            completion(.failure(.urlNotValid))
            return
        }

        let request = URLRequest(url: url)

        dataTask(with: request) { (data, response, error) in

            guard let data = data else { return }
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(.server(error: error)))
                }
            }

        }.resume()

    }

}
