//
//  old_mastervc.swift
//  Timely2
//
//  Created by Mihai Leonte on 8/10/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation

//    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
//        super.viewWillAppear(animated)
//
//        fetchTopStories() { topStoryIDs in
//
//            guard let topStories = topStoryIDs else {
//                print("No 'HN Top Stories' were fetched!")
//                return
//            }
//
//            for itemID in topStories {
//                var item = Item(id: itemID)
//                self.fetchedStories.append(item)
//            }
//            self.dataSource.update(with: self.fetchedStories)
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//
//        }
//    }

//                self.fetchItem(item: itemID) { item in
//                    guard let story = item else {
//                        print("New Item is null")
//                        return
//                    }
//                    self.fetchedStories.append(story)
//                    print("\(story.id)") // DEBUG
//
//                    self.dataSource.update(with: self.fetchedStories)
//                    // MARK: TODO - is this reload still necessary?
//                    // self.tableView.reloadData()
//                }




//func fetchTopStories(completion: @escaping ([Int]?) -> Void ) {
//    guard let topStories_URL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
//        completion(nil)
//        return
//    }
//    Alamofire.request(topStories_URL,
//                      method: .get)
//        .validate(statusCode: 200..<300)
//        .responseJSON { response in
//            guard response.result.isSuccess else {
//                print("Error while fetching HN Top Stories") // \(String(describing: response.result.error)
//                completion(nil)
//                return
//            }
//            
//            guard let value = response.result.value as? [Int] else {
//                print("Malformed data received from Top Stories service")
//                completion(nil)
//                return
//            }
//            
//            let stories = value.map { storyID in
//                return storyID }
//            
//            // MARK - LIMIT TODO
//            completion(Array(stories.prefix(20))) //.prefix(20) //get the first 20 items of the array
//    }
//}
//
//func fetchItem(item: Int, completion: @escaping (Item?) -> Void ) {
//    
//    guard let item_URL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(item).json") else {
//        completion(nil)
//        return
//    }
//    
//    Alamofire.request(item_URL,
//                      method: .get)
//        .validate(statusCode: 200..<300)
//        .responseJSON { response in
//            guard response.result.isSuccess else {
//                print("Error while fetching HN Item") // \(String(describing: response.result.error)
//                completion(nil)
//                return
//            }
//            
//            let json = JSON(response.result.value as Any) // MARK: - TODO fix force unwrap
//            
//            guard json["deleted"] == JSON.null else {
//                print("Deleted HN Item was skipped")
//                completion(nil)
//                return
//            }
//            
//            guard json["type"].stringValue == "story" else {
//                print("HN Item was skipped because it was not a story type.")
//                completion(nil)
//                return
//            }
//            
//            let title = json["title"].stringValue
//            guard let url = URL(string: json["url"].stringValue) else {
//                let url = ""
//                return
//            }
//            //let text = json["text"].stringValue
//            let by = json["by"].stringValue
//            let comments = json["descendants"].intValue
//            let score = json["score"].intValue
//            let unixtime = json["time"].doubleValue
//            let time = Date(timeIntervalSince1970: unixtime)
//            let kids = json["kids"].arrayValue.map { kidID in
//                return Item(id: kidID.intValue)
//            }
//            
//            completion(Item(id: item, title: title, url: url, by: by, descendants: comments, score: score, time: time, kids: kids))
//    }
//}
