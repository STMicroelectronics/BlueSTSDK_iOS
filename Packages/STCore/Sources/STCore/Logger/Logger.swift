//
//  Logger.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum LoggerCategory: String {
    case log
    case `deinit`
    case codable
    case atlantis_core
}

public enum LogLevel: UInt8 {
    case error = 1
    case warning = 2
    case critical = 3
    case debug = 4
    case info = 5
    case verbose = 6

    var tag: String {
        switch self {
        case .error:
            return "‼️"
        case .warning:
            return "⚠️"
        case .critical:
            return "🔥"
        case .debug:
            return "💬"
        case .info:
            return "ℹ️"
        case .verbose:
            return "🔬"
        }
    }
}

public enum LogMode {
    case full
    case long
    case short
    case custom(String)
}

public struct Logger {

    public static var level: LogLevel = .verbose
    public static var categories: [String] = []
    public static var defaultMode: LogMode = .full
    public static var defaultCategory = LoggerCategory.log.rawValue
    public static var excludedCategories: [String] = []
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()

    public static func log(level: LogLevel,
                           mode: LogMode = defaultMode,
                           category: String = defaultCategory,
                           text: String = "",
                           params: [String: CustomDebugStringConvertible] = [:],
                           filename: String = #file,
                           function: String = #function,
                           line: Int = #line) {
        
        guard level.rawValue <= Logger.level.rawValue else { return }

        if !categories.isEmpty {
            if (categories.contains { $0 == category }) == false {
                return
            }
        }

        if !excludedCategories.isEmpty {
            if (excludedCategories.contains { $0.uppercased() == category.uppercased() }) {
                return
            }
        }

        let url = URL(fileURLWithPath: filename)

        var parameters = ""
        params.forEach { tupla in
            parameters += "\n\t |--> \(tupla.key) = \(tupla.value.debugDescription)"
        }

        if !parameters.isEmpty {
            parameters += "\n"
        }

        let pattern: String

        switch mode {
        case .full:
            pattern = "[%datetime] [%level] [%category] (%file.%function:%line) %text %params"
        case .long:
            pattern = "[%level] [%category] (%file.%function:%line) %text %params"
        case .short:
            pattern = "[%level] [%category] %text %params"
        case .custom(let customPattern):
            pattern = customPattern
        }

        // swiftlint:disable line_length
        var message = pattern.replacingOccurrences(of: "%datetime", with: Self.dateFormatter.string(from: Date()), options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%level", with: level.tag, options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%category", with: category.uppercased(), options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%file", with: url.lastPathComponent, options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%function", with: function, options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%line", with: "\(line)", options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%text", with: text, options: .literal, range: nil)
        message = message.replacingOccurrences(of: "%params", with: parameters, options: .literal, range: nil)
        // swiftlint:enable line_length

        print(message)
    }

    public static func debug(mode: LogMode = defaultMode,
                             category: String = defaultCategory,
                             text: String,
                             params: [String: CustomDebugStringConvertible] = [:],
                             filename: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        Logger.log(level: .debug,
                   mode: mode,
                   category: category,
                   text: text,
                   params: params,
                   filename: filename,
                   function: function,
                   line: line)
    }
}
