//
//  Logger.swift
//  entourage
//
//  Created by Jr on 06/06/2019.
//  Copyright © 2019 Jr. All rights reserved.
//

import Foundation

public struct Logger {
    
    private static let isDebug = false
    private static var dateFormatter: DateFormatter?
    
    // MARK: - Printing functions
    public static func print(_ args: Any..., file: String = #file) {
        #if DEBUG
            var string = "[\(self.sanitizeFile(file: file))]"
            for arg in args {
                string += " \(arg)"
            }
            Swift.print("\(self.makeDate()) \(string)")
        #endif
    }
    
    // MARK: - Helpers
    private static func makeDate() -> String {
        if self.dateFormatter == nil {
            self.dateFormatter = DateFormatter()
            self.dateFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            self.dateFormatter?.dateFormat = "HH:mm:ss"
        }
        
        guard let date = self.dateFormatter?.string(from: NSDate() as Date) else { return "" }
        
        return date
    }
    
    private static func sanitizeFile(file: String) -> String {
        return (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    }
}
