////
////  Item.swift
////  Timely2
////
////  Created by Mihai Leonte on 9/8/18.
////  Copyright © 2018 Mihai Leonte. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//
//enum ItemType: String, Decodable {
//    case story
//    case comment
//    case ask
//    case job
//    case poll
//    case pollopt //part of poll
//    
//    enum CodingKeys : String, CodingKey {
//        case story
//        case comment
//        case ask
//        case job
//        case poll
//        case pollopt
//    }
//}
//
//enum ItemState: String, Decodable {
//    case new
//    case downloading
//    case downloaded
//    case failed
//}
//
//class Item: Decodable {
//    let id: Int              // the only required property
//    var state: ItemState?
//    var deleted: Bool?       // true if the item is deleted
//    var type: ItemType?      // The type of item. One of "job", "story", "comment", "poll", or "pollopt".
//    var by: String?          // the username of the item's author
//    var time: Date?          // create date of the item in unix time -  .secondsSince1970
//    var text: String?        // the comment, story or poll text. HTML
//    var dead: Bool?          // true if the item is dead
//    var parent: Int?         // The comment's parent: either another comment or the relevant story.
//    var poll: Int?           // The pollopt's associated poll.
//    var kids: [Item]?         // The ids of the item's comments, in ranked display order
//    var url: URL?            // the URL of the story
//    var score: Int?          // the story's score or the votes for a pollopt
//    var title: String?       // the title of the story, poll or job
//    var parts: [Int]?        // A list of related pollopts, in display order.
//    var descendants: Int?    // in the case of stories or polls, the total comment count
//    
//    init(id: Int,
//        state: ItemState = .new,
//        deleted: Bool? = nil,
//        type: ItemType? = nil,
//        by: String? = nil,
//        time: Date? = nil,
//        text: String? = nil,
//        dead: Bool? = nil,
//        parent: Int? = nil,
//        poll: Int? = nil,
//        kids: [Item]? = nil,
//        url: URL? = nil,
//        score: Int? = nil,
//        title: String? = nil,
//        parts: [Int]? = nil,
//        descendants: Int? = nil) {
//        
//        self.id = id
//        self.state = state
//        self.deleted = deleted
//        self.type = type
//        self.by = by
//        self.time = time
//        self.text = text
//        self.dead = dead
//        self.parent = parent
//        self.poll = poll
//        self.kids = kids
//        self.url = url
//        self.score = score
//        self.title = title
//        self.parts = parts
//        self.descendants = descendants
//    }
//    
//    enum CodingKeys : String, CodingKey {
//        case id
//        case deleted
//        case type
//        case by
//        case time
//        case text
//        case dead
//        case parent
//        case poll
//        case kids
//        case url
//        case score
//        case title
//        case parts
//        case descendants
//    }
//
//
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        
//        id = try values.decode(Int.self, forKey: .id)
//        state = .new
//        deleted = try values.decodeIfPresent(Bool.self, forKey: .deleted)
//        type = try values.decodeIfPresent(ItemType.self, forKey: .type)
//        
//        by = try values.decodeIfPresent(String.self, forKey: .by)
//        time = try values.decodeIfPresent(Date.self, forKey: .time)
//        text = try values.decodeIfPresent(String.self, forKey: .text)
//        dead = try values.decodeIfPresent(Bool.self, forKey: .dead)
//        parent = try values.decodeIfPresent(Int.self, forKey: .parent)
//        poll = try values.decodeIfPresent(Int.self, forKey: .poll)
//
//        //Kids is nil
//        let kidsArrayOptional: [Int]? = try values.decodeIfPresent([Int].self, forKey: .kids)
//        var kidsList: [Item] = []
//        if let kidsArray = kidsArrayOptional {
//            for kidInt in kidsArray {
//                kidsList.append(Item(id: kidInt))
//            }
//        }
//        if kidsList.count > 0 {
//            kids = kidsList
//        }
//        
//        url = try values.decodeIfPresent(URL.self, forKey: .url)
//        score = try values.decodeIfPresent(Int.self, forKey: .score)
//        title = try values.decodeIfPresent(String.self, forKey: .title)
//        parts = try values.decodeIfPresent([Int].self, forKey: .parts)
//        descendants = try values.decodeIfPresent(Int.self, forKey: .descendants)
//    }
//}
//
//extension Item {
//    func update(withComment newItem: Item) {
//        func traverse(item: Item) {
//            
//            if let kids = item.kids {
//                if kids.isEmpty {
//                    return
//                }
//                
//                for kid in kids {
//                    if kid.id == newItem.id {
//                        kid.deleted = newItem.deleted
//                        kid.type = newItem.type
//                        kid.by = newItem.by
//                        kid.time = newItem.time
//                        kid.text = newItem.text
//                        kid.dead = newItem.dead
//                        kid.parent = newItem.parent
//                        kid.poll = newItem.poll
//                        kid.kids = newItem.kids
//                        kid.url = newItem.url
//                        kid.score = newItem.score
//                        kid.title = newItem.title
//                        kid.parts = newItem.parts
//                        kid.descendants = newItem.descendants
//                    } else {
//                        traverse(item: kid)
//                    }
//                }
//                
//            }
//            
//        }
//        
//        traverse(item: self)
//    }
//}
