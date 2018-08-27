//
//  Logger.swift
//  Mixed
//
//  Created by Jay Lees on 27/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public enum LogType: String {
    case error = "ERROR"
    case debug = "DEBUG"
    case warning = "WARNING"
    case severe = "SEVERE"
}

public class Logger {
    static var dateFormat = "yyyy-MM-dd HH:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public static func log(_ object: Any, type: LogType, file: String = #file, line: Int = #line, funcName: String = #function ) {
        #if DEBUG
        var output = "\(dateFormatter.string(from: Date())) "
        output += "[\(type.rawValue)] \(sourceFileName(file)):\(line) -> \(object)"
        print(output)
        #endif
    }
    
    private class func sourceFileName(_ filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}


