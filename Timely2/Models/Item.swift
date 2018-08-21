//
//  Item.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/26/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// HN Item endpoint
let ITEM_ENDPOINT = "https://hacker-news.firebaseio.com/v0/item/" //{id}.json

// This enum contains all the possible states an item can be in
enum ItemState {
    case new, downloading, downloaded, failed
}

class Item {
    let id: Int
    var state = ItemState.new
    var by: String? //the username of the item's author
    var time: Date? //create date of the item in unix time
    var text: String? //the comment, story or poll text. HTML
    var kids: [Item] //The ids of the item's comments, in ranked display order
    var url: URL? //the URL of the story
    var score: Int? //the story's score or the votes for a pollopt
    var title: String? //the title of the story, poll or job
    var descendants: Int? //in the case of stories or polls, the total comment count
    //let deleted: Bool? //true if item is deleted
    //let type: String? //job, sotry, comment, poll or pollopt
    //let dead: Bool? //true if the item is dead
    //let parent: Int? //the comment's parent: either another comment or the relevant story
    //let poll: String? //The pollopts's associated pol //TODO - Is the type correct?
    //let parts: String? //a list of related pollopts in display order //TODO - Is the type correct?
    
    
    //ID Init
    init(id: Int) {
        self.id = id
        self.by = nil
        self.time = nil
        self.kids = []
        self.text = nil
        self.title = nil
        self.url = nil
        self.descendants = nil
        self.score = nil
    }
    
    //Story Init
    init(id: Int, title: String?, url: URL, by: String, descendants: Int, score: Int, time: Date, kids: [Item]) {
        self.id = id
        self.title = title
        self.url = url
        self.by = by
        self.descendants = descendants
        self.score = score
        self.time = time
        self.kids = kids
        self.text = nil
    }
    
    //Comment Init
    init(id: Int, by: String, text: String, time: Date, kids: [Item]) {
        self.id = id
        self.by = by
        self.time = time
        self.kids = kids
        self.text = text
        self.title = nil
        self.url = nil
        self.descendants = nil
        self.score = nil
    }
    
    //Update item
//    func updateItem(with fullItem: Item) {
//        self.by = fullItem.by
//        self.time = fullItem.time
//        self.kids = fullItem.kids
//        self.text = fullItem.text
//        self.title = fullItem.title
//        self.url = fullItem.url
//        self.descendants = fullItem.descendants
//        self.score = fullItem.score
//    }
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
    let item: Item

    
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
                        return Item(id: kidID.intValue)
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
        taskItem.resume()
        
        if isCancelled {
            return
        }
        
    }
}
