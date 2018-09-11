//
//  Item.swift
//  Timely2
//
//  Created by Mihai Leonte on 9/8/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation

enum ItemType : String, Decodable {
    case story
    case comment
    case ask
    case job
    case poll
    case pollopt //part of poll
}

struct Item : Decodable {
    let id: Int              // the only required property
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
