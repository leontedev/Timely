//
//  OSLog.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")
}
