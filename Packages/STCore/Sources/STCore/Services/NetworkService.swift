//
//  NetworkService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Combine

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

public extension HTTPCodes {
    static let success = 200 ..< 300
}

public struct Response<T> {
    public let value: T?

    public init(value: T?) {
        self.value = value
    }
}

public struct EmptyObject: Codable {
    var message: String?

    public init() {

    }

    enum CodingKeys: String, CodingKey {
        case message
    }
}

public protocol Endpoint {
    var path: String { get }
    var url: URL { get }
    var queryItems: [URLQueryItem] { get }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Authentication {
    case none
    case bearer
    case basic
}

// swiftlint:disable line_length

public protocol Network {

    var timeout: TimeInterval { get set }

    var pinnedCertificates: [SecCertificate] { get }

    func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingFormatter: DateFormatter,
                                                      dateDecodingFormatter: DateFormatter) -> AnyPublisher<Response<Output>, STError>

    func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<Response<Output>, STError>
}

public class NetworkService: NSObject, Network {
    public var timeout: TimeInterval = 5.0
    public var pinnedCertificates: [SecCertificate] = []

    static let defaultHeaders = [
        "Content-Type": "application/json",
        "cache-control": "no-cache"
    ]

    public convenience init(timeout: TimeInterval, pinnedCertificates: [SecCertificate]) {
        self.init()
        self.timeout = timeout
        self.pinnedCertificates = pinnedCertificates
    }

    internal func buildHeaders(authentication: Authentication,
                               headers: [String: String]) -> [String: String]? {

        var defaultHeaders = NetworkService.defaultHeaders

        defaultHeaders = defaultHeaders.merging(headers) { (_, newValue) in newValue }

        guard let session: NetworkSession = Resolver.shared.resolve() else { return nil }

        if authentication == .bearer {
            let header = "Bearer \(session.accessToken ?? "no_valid_token_found")"
            defaultHeaders["Authorization"] = header
        } else if let username = session.username,
                  let password = session.password,
                  authentication == .basic {
            defaultHeaders["Authorization"] = NetworkService.basicAuthenticationHeader(username: username,
                                                                                       password: password)
        }

        return defaultHeaders
    }

    func run<Output>(_ request: URLRequest,
                     dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                     rootKey: String?) throws -> AnyPublisher<Response<Output>, STError> where Output: Decodable {

        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)

        return session
            .dataTaskPublisher(for: request)
            .jsonResponse(httpCodes: HTTPCodes.success, dateDecodingStrategy: dateDecodingStrategy, rootKey: rootKey)
            .receive(on: DispatchQueue.main)
            .mapCustomError()
            .eraseToAnyPublisher()
    }

    public func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<Response<Output>, STError> {
        do {
            var components = URLComponents(url: endpoint.url,
                                           resolvingAgainstBaseURL: true)

            if endpoint.queryItems.count != 0 {
                components?.queryItems = endpoint.queryItems
            }

            guard let url = components?.url else {
                return Fail<Response<Output>, STError>(error: STError.urlNotValid)
                    .eraseToAnyPublisher()
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = buildHeaders(authentication: authentication, headers: headers)
            request.timeoutInterval = timeout

            if type(of: body) != EmptyObject?.self {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = dateEncodingStrategy
                let bodyData = try? encoder.encode(body)
                request.httpBody = bodyData
            } else if params.keys.count > 0 {
                request.httpBody = encodeParameters(parameters: params)
            }

            return try run(request, dateDecodingStrategy: dateDecodingStrategy, rootKey: rootKey)
                .eraseToAnyPublisher()
        } catch let error {
            return Fail<Response<Output>, STError>(error: STError.server(error: error))
                .eraseToAnyPublisher()
        }
    }

    public func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication = .none,
                                                      dateEncodingFormatter: DateFormatter = DateFormatter.iso8601Full,
                                                      dateDecodingFormatter: DateFormatter = DateFormatter.iso8601Full) -> AnyPublisher<Response<Output>, STError> {
        Logger.debug(text: "/// API /// - \(endpoint)")
        return request(endpoint,
                       method: method,
                       body: body,
                       headers: headers,
                       params: params,
                       rootKey: rootKey,
                       authentication: authentication,
                       dateEncodingStrategy: .formatted(dateEncodingFormatter),
                       dateDecodingStrategy: .formatted(dateDecodingFormatter))
    }
}

public extension NetworkService {
    static func basicAuthenticationHeader(username: String, password: String) -> String {
        let userPasswordString = "\(username):\(password)"
        let userPasswordData = userPasswordString.data(using: .utf8)

        guard let base64EncodedCredential = userPasswordData?.base64EncodedString() else { return "" }

        return "Basic \(base64EncodedCredential)"
    }

    func encodeParameters(parameters: [String : String]) -> Data? {
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        }

        return parameterArray.joined(separator: "&").data(using: .utf8)
    }
}

private extension Publisher where Output == URLSession.DataTaskPublisher.Output {

    func jsonResponse<Output>(httpCodes: HTTPCodes,
                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                              rootKey: String?) -> AnyPublisher<Response<Output>, Error> where Output: Decodable {
        return tryMap { result in
            guard let code = (result.response as? HTTPURLResponse)?.statusCode else {
                throw STError.unknown
            }
            guard httpCodes.contains(code) else {

                if code == 401 {
                    throw STError.notAuthorized
                }

                throw STError.raw(data: result.data)
            }

            if code == 204 {
                return Response<Output>(value: nil)
            }

            if result.data.count == 0 {
                return Response<Output>(value: nil)
            } else if Output.self == Data.self {
                return Response<Output>(value: result.data as? Output)
            } else {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                do {
                    let text = String(data: result.data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: text,
                                     params: [:])
                    }

                    guard let rootKey = rootKey else {
                        let object = try decoder.decode(Output.self, from: result.data)
                        return Response<Output>(value: object)
                    }

                    let object = try decoder.decode(Output.self, from: result.data, keyedBy: rootKey)
                    return Response<Output>(value: object)

                } catch let error {
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: error.localizedDescription,
                                     params: [:])
                    }
                }
                return Response<Output>(value: nil)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func mapCustomError() -> AnyPublisher<Self.Output, STError> {
        return self.mapError { error in
            guard let unwrappedError = error as? STError else {
                return STError.server(error: error)
            }

            return unwrappedError

        }
        .eraseToAnyPublisher()
    }
}

extension NetworkService: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let trust = challenge.protectionSpace.serverTrust,
           pinnedCertificates.count > 0 {

            SecTrustSetAnchorCertificates(trust, pinnedCertificates as CFArray)
            SecTrustSetAnchorCertificatesOnly(trust, true)

            let serverCertificatesData = Set(trust.certificates.data)
            let pinnedCertificatesData = Set(pinnedCertificates.data)

            if !serverCertificatesData.isDisjoint(with: pinnedCertificatesData) {
                let credential:URLCredential =  URLCredential(trust:trust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }

        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension Array where Element: SecCertificate {
    /// All `Data` values for the contained `SecCertificate`s.
    public var data: [Data] {
        map { SecCertificateCopyData($0) as Data }
    }

}

extension SecTrust {
    public var certificates: [SecCertificate] {
        (0..<SecTrustGetCertificateCount(self)).compactMap { index in
            SecTrustGetCertificateAtIndex(self, index)
        }
    }
}
