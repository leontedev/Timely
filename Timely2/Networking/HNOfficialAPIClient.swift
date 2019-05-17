//
//  HNOfficialAPIClient.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/14/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class HNOfficialAPIClient {
  let downloader = JSONDownloader()
  
  
  func fetchOfficialApiStoryIds(from urlComponents: URLComponents, completion: @escaping (Result<[String], HackerNewsError>) -> Void) {
    
    guard let url = urlComponents.url else {
      completion(.failure(.invalidURL))
      return
    }
    
    let request = URLRequest(url: url)
    
    let task = downloader.jsonTask(with: request) { jsonResult in
      
      DispatchQueue.main.async {
        
        switch jsonResult {
        case .success(let json):
          do {
            let decoder = JSONDecoder()
            let stories = try decoder.decode([Int].self, from: json)
            let storyIDs = stories.map { String($0) }
            
            completion(.success(storyIDs))
          } catch let error {
            completion(.failure(HackerNewsError.jsonParsingFailure(message: error.localizedDescription)))
          }
        case .failure(let error):
          completion(.failure(error))
        }
        
      }
    }
    
    task.resume()
    
  }
  
}
