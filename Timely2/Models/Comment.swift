//
//  Comment.swift
//  Timely2
//
//  Created by Mihai Leonte on 12/17/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//


// https://hn.algolia.com/api Implementation for the Comments
import Foundation

//id: 1,
//created_at: "2006-10-09T18:21:51.000Z" //ISO 8601 format
//author: "pg",
//title: "Y Combinator",
//url: "http://ycombinator.com",
//text: null,
//points: 57,
//parent_id: null,
//children: [Comment]

class Comment : Codable {
    
    var id: Int
    var created_at: Date
    var author: String?
    var title: String?
    var url: URL?
    var text: String?
    var points: Int?
    var parent_id: Int?
    var children: [Comment]?
    
    init(id: Int,
         created_at: Date,
         author: String?,
         title: String?,
         url: URL?,
         text: String?,
         points: Int?,
         parent_id: Int?,
         children: [Comment]?) {
        
        self.id = id
        self.created_at = created_at
        self.author = author
        self.title = title
        self.url = url
        self.text = text
        self.points = points
        self.parent_id = parent_id
        self.children = children
    }
}
