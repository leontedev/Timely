//
//  FileManager.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

// the Documents directory URL
extension FileManager {
    static var documentDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
