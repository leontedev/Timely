//
//  AlgoliaItem.swift
//  Timely2
//
//  Created by Mihai Leonte on 1/7/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//



struct AlgoliaItemList: Codable {
    let hits: [Story]
}

struct AlgoliaItemResult: Codable {
    let results: [Story]
}


class Story: Codable, Hashable, Equatable {
    
    static func == (lhs: Story, rhs: Story) -> Bool {
        return lhs.objectID == rhs.objectID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
    }
    
    let created_at: Date
    let title: String?
    let url: URL?
    let author: String?
    let story_text: String?
    let points: Int?
    let num_comments: Int?
    let created_at_i: Int?
    let objectID: String
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        created_at = try values.decode(Date.self, forKey: .created_at)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        
        if let urlString = try values.decodeIfPresent(String.self, forKey: .url) {
            if let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let urlProper = URL(string: urlEncoded) {
                    url = urlProper
                } else {
                    url = nil
                }
            } else {
                url = nil
            }
        } else {
            url = nil
        }
        
        author = try values.decodeIfPresent(String.self, forKey: .author)
        story_text = try values.decodeIfPresent(String.self, forKey: .story_text)
        points = try values.decodeIfPresent(Int.self, forKey: .points)
        num_comments = try values.decodeIfPresent(Int.self, forKey: .num_comments)
        created_at_i = try values.decodeIfPresent(Int.self, forKey: .created_at_i)
        objectID = try values.decode(String.self, forKey: .objectID)
    }
}
