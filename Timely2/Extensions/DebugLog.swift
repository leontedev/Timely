//
//  DebugLog.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/5/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation


/// Logs the message to the console with extra information, e.g. file name, method name and line number
///
/// To make it work you must set the "DEBUG" symbol, set it in the "Swift Compiler - Custom Flags" section, "Other Swift Flags" line.
/// You add the DEBUG symbol with the -D DEBUG entry.

public func debugLog(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    var debugOutput = "[\(className):\(lineNumber) \(functionName)."
    
//    if let debugObject = object {
//        debugOutput += ": \(debugObject)"
//    }
//
//    if let debugMessage = message {
//        debugOutput += ". \(debugMessage)"
//    }
    
    debugOutput += "\n"
    print(debugOutput)
    #endif
}
