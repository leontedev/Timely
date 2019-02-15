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
    case network(String)
}

extension HNError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .badURL(fromString: let string):
            return NSLocalizedString("Error with status Bad URL was thrown.\nMalformed URL:  \(string)", comment: "Bad URL")
            
        case .parsingJSON(let message):
            return "JSON parsing failed. \(message)"
            
        case .network(let message):
            return "Call request failure. Status: \(message)"
            
        }
    }
}
