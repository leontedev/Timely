//
//  AlgoliaAPI.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/10/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
import InstantSearchClient


class AlgoliaAPIClient {
  let downloader = JSONDownloader()
  

  func fetchStoryDetails(for storyIDs: [String], completion: @escaping (Result<[AlgoliaItem], HackerNewsError>) -> Void) {
    let algoliaClient = Client(appID: "UJ5WYC0L7X", apiKey: "8ece23f8eb07cd25d40262a1764599b1")
    let algoliaIndex = algoliaClient.index(withName: "Item_production")
    
    let subset = Array(storyIDs.prefix(300))
    
    // all attributes are received if attributesToRetrieve is sent as nil
    algoliaIndex.getObjects(withIDs: subset, attributesToRetrieve: ["created_at", "title", "url", "author", "story_text", "points", "num_comments", "created_at_i"]) { content, error in
      
      DispatchQueue.main.async {
        
        guard let json = content else {
          completion(.failure(HackerNewsError.requestFailed))
          return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: json["results"])
          let stories = try decoder.decode([AlgoliaItem?].self, from: jsonData)
          let results = stories.compactMap { $0 }
          
          completion(.success(results))
          
        } catch let error {
          completion(.failure(HackerNewsError.jsonParsingFailure(message: "Unexpected server response")))
        }
        
      }
      
    }
  }

  
  func fetchAlgoliaApiStories(from urlComponents: URLComponents, completion: @escaping (Result<[AlgoliaItem], HackerNewsError>) -> Void) {
    
    guard let url = urlComponents.url else {
      completion(.failure(.invalidURL))
      return
    }
    
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
    
    let task = downloader.jsonTask(with: request) { jsonResult in
      
      DispatchQueue.main.async {
        
        switch jsonResult {
        case .success(let json):
          do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .customISO8601
            let stories = try decoder.decode(AlgoliaItemList.self, from: json)
            
            let hits = stories.hits
            
            completion(.success(hits))
            
          } catch let error {
            completion(.failure(.jsonParsingFailure(message: error.localizedDescription)))
          }
        case .failure(let error):
          completion(.failure(error))
        }
        
      }
    }
    
    task.resume()
    
  }
}
