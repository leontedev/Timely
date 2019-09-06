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
  

  func fetchStories(for storyIDs: [String], completion: @escaping (Result<[Story], HackerNewsError>) -> Void) {
    let algoliaClient = Client(appID: "UJ5WYC0L7X", apiKey: "8ece23f8eb07cd25d40262a1764599b1")
    let algoliaIndex = algoliaClient.index(withName: "Item_production")
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let subset = Array(storyIDs.prefix(300))
    
    // all attributes are received if attributesToRetrieve is sent as nil
    algoliaIndex.getObjects(withIDs: subset, attributesToRetrieve: ["created_at", "title", "url", "author", "story_text", "points", "num_comments", "created_at_i"]) { content, error in
      
      DispatchQueue.main.async {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let json = content else {
          completion(.failure(HackerNewsError.requestFailed))
          return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: json["results"] as Any)
          let stories = try decoder.decode([Story?].self, from: jsonData)
          let results = stories.compactMap { $0 }
          
          completion(.success(results))
          
        } catch _ {
          completion(.failure(HackerNewsError.jsonParsingFailure(message: "Unexpected server response")))
        }
        
      }
      
    }
  }

  
  func fetchStories(from urlComponents: URLComponents, completion: @escaping (Result<[Story], HackerNewsError>) -> Void) {
    
    guard let url = urlComponents.url else {
      completion(.failure(.invalidURL))
      return
    }
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
    
    let task = downloader.jsonTask(with: request) { jsonResult in
      
      DispatchQueue.main.async {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
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
  
  func fetchComments(forItemID storyID: String, completion: @escaping (Result<[CommentSource], HackerNewsError>) -> Void) {
    
    var comments: [CommentSource] = []
    
    var isSetToUseCustomFontForComments: Bool { return UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForComments") }
    var customFontSizeComments: Float { return UserDefaults.standard.float(forKey: "customFontSizeComments") }
    var prefferedFontSize: UIFont {
      
      if isSetToUseCustomFontForComments {
        let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeComments))
        return UIFontMetrics.default.scaledFont(for: font)
      } else {
        return .preferredFont(forTextStyle: .body)
      }
      
    }
    
    func DFS(forItem item: Comment, depth: Int) {
      if let nestedItems = item.children {
        if !nestedItems.isEmpty {
          for nestedItem in nestedItems {
            if let _ = nestedItem.text {
              //commentsFlatArray.append((nestedItem, depth))
              comments.append(CommentSource(comment: nestedItem,
                                                 depth: depth,
                                                 timeAgo: nil,
                                                 height: nil,
                                                 collapsed: false,
                                                 removedComments: [],
                                                 attributedString: nil))
              DFS(forItem: nestedItem, depth: depth+1)
            }
          }
        }
      }
    }
    

    let commentUrl = "https://hn.algolia.com/api/v1/items/\(storyID)"
    
    guard let url = URL(string: commentUrl) else {
      completion(.failure(.invalidURL))
      return
    }
    
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let _ = downloader.jsonTask(with: request) { jsonResult in
      
      DispatchQueue.main.async {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        switch jsonResult {
        case .success(let json):
          do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .customISO8601
            
            let fetchedComments = try decoder.decode(Comment.self, from: json)
            
            //if let comments = fetchedComments {
            if let childrenComments = fetchedComments.children {
              for childComment in childrenComments {
                if let _ = childComment.text {
                  comments.append(CommentSource(comment: childComment,
                                                     depth: 0,
                                                     timeAgo: nil,
                                                     height: nil,
                                                     collapsed: false,
                                                     removedComments: [], attributedString: nil))
                  DFS(forItem: childComment,
                      depth: 1)
                }
                
              }
            }
            
            
            let _ = CFAbsoluteTimeGetCurrent()
            let componentsFormatter = DateComponentsFormatter()
            
            // For parsing the 'Elapsed Time' Date to a 'Time Ago' String
            componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
            componentsFormatter.maximumUnitCount = 1
            componentsFormatter.unitsStyle = .abbreviated
            
            // HTML Parsing / Attributed String Options
            let color = UIColor.black
            
            let options = [
              DTCoreTextStub.kDTCoreTextOptionKeyFontSize(): prefferedFontSize.fontDescriptor.pointSize,
              DTCoreTextStub.kDTCoreTextOptionKeyFontName(): prefferedFontSize.fontName,
              DTCoreTextStub.kDTCoreTextOptionKeyFontFamily(): prefferedFontSize.familyName, //UIFont.systemFont(ofSize: 14).familyName, //"Helvetica Neue",
              DTCoreTextStub.kDTCoreTextOptionKeyUseiOS6Attributes(): NSNumber(value: true),
              DTCoreTextStub.kDTCoreTextOptionKeyTextColor(): color] as [String? : Any]
            
            for (index, comment) in comments.enumerated() {
              
              let epochTime = comment.comment.created_at
              let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
              comments[index].timeAgo = timeAgo
              
              // Parse html in the .text parameter to NSAttributedString
              // Start working on a background thread - if parsing will not be ready, it will be done 'live' when displaying the row on the main thread
              //                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
              //                            guard let self = self else {
              //                                return
              //                            }
              
              if let commentText = comment.comment.text {
                guard let attributedString = DTCoreTextStub.attributedString(withHtml: commentText, options: options) else {
                  return
                }
                
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString.trimmingCharacters(in: .whitespacesAndNewlines))
                
                let range = NSMakeRange(0, attributedString.length)
                mutableAttributedString.mutableString.replaceOccurrences(of: "\n\n", with: "\n", options: NSString.CompareOptions.caseInsensitive, range: range)
                
                comments[index].attributedString = mutableAttributedString
              }
            }
            
            completion(.success(comments))
            
          } catch let error {
            completion(.failure(.jsonParsingFailure(message: error.localizedDescription)))
          }
        case .failure(let error):
          completion(.failure(error))
        }
        
      }
    
    }.resume()
  
  }
}
