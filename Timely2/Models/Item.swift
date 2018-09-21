//
//  Item.swift
//  Timely2
//
//  Created by Mihai Leonte on 9/8/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum ItemType : String, Decodable {
    case story
    case comment
    case ask
    case job
    case poll
    case pollopt //part of poll
}

enum ItemState : String, Decodable {
    case new
    case downloading
    case downloaded
    case failed
}

struct Item : Decodable {
    let id: Int              // the only required property
    var state: ItemState
    var deleted: Bool?       // true if the item is deleted
    var type: ItemType?      // The type of item. One of "job", "story", "comment", "poll", or "pollopt".
    var by: String?          // the username of the item's author
    var time: Date?          // create date of the item in unix time -  .secondsSince1970
    var text: String?        // the comment, story or poll text. HTML
    var dead: Bool?          // true if the item is dead
    var kids: [Int]?         // The ids of the item's comments, in ranked display order
    var url: URL?            // the URL of the story
    var score: Int?          // the story's score or the votes for a pollopt
    var title: String?       // the title of the story, poll or job
    var parts: [Int]?        // A list of related pollopts, in display order.
    var descendants: Int?    // in the case of stories or polls, the total comment count
    
    init(id: Int,
        state: ItemState = .new,
        deleted: Bool? = nil,
        type: ItemType? = nil,
        by: String? = nil,
        time: Date? = nil,
        text: String? = nil,
        dead: Bool? = nil,
        kids: [Int]? = nil,
        url: URL? = nil,
        score: Int? = nil,
        title: String? = nil,
        parts: [Int]? = nil,
        descendants: Int? = nil) {
        
        self.id = id
        self.state = state
        self.deleted = deleted
        self.type = type
        self.by = by
        self.time = time
        self.text = text
        self.dead = dead
        self.kids = kids
        self.url = url
        self.score = score
        self.title = title
        self.parts = parts
        self.descendants = descendants
    }
}

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1 //By default it optimizes based on device
        return queue
    }()
}




class ItemDownloader: Operation {
    var item: Item
    
    init(_ item: Item) {
        self.item = item
    }
    
    override func main() {
        
        // Change the state of the item - otherwise it will loop continuously as the downloader completion blocks reloads the table row.
        self.item.state = .downloading
        
        if isCancelled {
            return
        }
        
        // Construct the URL
        let itemID = String(item.id)
        let urlString = "https://hacker-news.firebaseio.com/v0/item/\(itemID).json"
        print(urlString)
        let requestItem = URLRequest(url: URL(string: urlString)!)
        let taskItem = URLSession(configuration: .default).dataTask(with: requestItem) { data, response, error in
            self.item.state = .downloaded
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                
                print("200 OK on Item ID = \(itemID)")
                do {
                    let json = try JSON(data:data!)
                    self.item.state = .downloaded
                    finish(true)
                    
                    guard json["deleted"] == JSON.null else {
                        print("Deleted HN Item was skipped")
                        return
                    }
                    
                    guard json["type"].stringValue == "story" else {
                        print("HN Item was skipped because it was not a story type.")
                        return
                    }
                    
                    let title = json["title"].stringValue
                    guard let url = URL(string: json["url"].stringValue) else {
                        return
                    }
                    
                    //let text = json["text"].stringValue
                    let by = json["by"].stringValue
                    let comments = json["descendants"].intValue
                    let score = json["score"].intValue
                    let unixtime = json["time"].doubleValue
                    let time = Date(timeIntervalSince1970: unixtime)
                    let kids = json["kids"].arrayValue.map { kidID in
                        return kidID.intValue //Item(id: kidID.intValue)
                    }
                    
                    self.item.title = title
                    self.item.url = url
                    self.item.by = by
                    self.item.descendants = comments
                    self.item.score = score
                    self.item.time = time
                    self.item.kids = kids
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                    self.item.state = .failed
                }
            }
            
        }
        // THIS RIGHT HERE IS THE PROBLEM
        taskItem.resume()
        
        if isCancelled {
            return
        }
        
    }
}
