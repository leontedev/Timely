//
//  HNError.swift
//  Timely2
//
//  Created by Mihai Leonte on 2/13/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

enum HNError: Error {
    case badURL(fromString: String)
    case parsingJSON(String)
    case network
}
