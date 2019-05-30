//
//  JSONDownloader.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/14/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class JSONDownloader {
  let session: URLSession
  
  init(configuration: URLSessionConfiguration) {
    self.session = URLSession(configuration: configuration)
  }
  
  convenience init() {
    let configuration = URLSessionConfiguration.default
    configuration.waitsForConnectivity = true
    self.init(configuration: configuration)
  }
  
  typealias JSONTaskCompletionHandler = (Result<Data, HackerNewsError>) -> Void
  
  func jsonTask(with request: URLRequest, completionHandler completion: @escaping  JSONTaskCompletionHandler) -> URLSessionDataTask {
    
    let task = session.dataTask(with: request) { data, response, error in
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(.requestFailed))
        return
      }
      
      if httpResponse.statusCode == 200 {
        if let data = data {
          
          completion(.success(data))

        } else {
          completion(.failure(.invalidData))
        }
      } else {
        completion(.failure(.responseUnsuccessful))
      }
      
    }
    
    return task
  }
}
