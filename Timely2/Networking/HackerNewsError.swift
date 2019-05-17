//
//  HackerNewsError.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/14/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

enum HackerNewsError: Error {
  case invalidURL
  case requestFailed
  case responseUnsuccessful
  case invalidData
  case jsonConversionFailure
  case jsonParsingFailure(message: String)
}

extension HackerNewsError: LocalizedError {
  public var errorDescription: String? {
    switch self {
      
    case .invalidURL:
      return NSLocalizedString("Invalid URL.", comment: "Bad URL")
      
    case .jsonParsingFailure(let message):
      return "JSON parsing failed. \(message)"
      
    default:
      return "Call request failure."
      
    }
  }
}
