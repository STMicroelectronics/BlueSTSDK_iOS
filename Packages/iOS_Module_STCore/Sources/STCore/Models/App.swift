//
//  App.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AppMode: Codable {
    case beginner
    case expert
    case none
}

public enum UserType: Int, Codable {
    case developer = 0
    case studentOrResearcher
    case engineerOrSale
    case other
    case none
}

public struct App {
    public let appMode: AppMode
    public let userType: UserType
}

extension App: Codable {
    enum CodingKeys: String, CodingKey {
        case appMode
        case userType
    }
}

extension AppMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .expert:
            return "Expert"
        case .none:
            return "None"
        }
    }
}

extension UserType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .developer:
            return "Developer"
        case .studentOrResearcher:
            return "Student or Researcher"
        case .engineerOrSale:
            return "Engineer or Sale"
        case .other:
            return "Other"
        case .none:
            return "None"
        }
    }
}
