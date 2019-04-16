//
//  History.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static var historyAdded: Notification.Name {
        return .init(rawValue: "History.addedNewId")
    }
    
}

public struct HistoryItem: Codable, Hashable, Equatable {
    public let id: String
    public let bookmarkDate: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.id == rhs.id
    }
}


public class History {
    static let shared = History()
    var items: Set<HistoryItem> = []
    var stories: [Item] {
        var stories: [Item] = []
        
        // show the newest visited stories first
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        let sortedSet = self.items.sorted(by: { $0.bookmarkDate > $1.bookmarkDate } )
        
        for item in sortedSet {
            guard let id = Int(item.id) else { continue }
            stories.append(Item(id: id))
        }
        return stories
    }
    
    let url = FileManager.documentDirectoryURL.appendingPathComponent("history").appendingPathExtension("plist")
    
    private init() {
        // load previously saved Bookmarks from Documents / Bookmarks.plist
        do {
            print(FileManager.documentDirectoryURL.path)
            let plistDecoder = PropertyListDecoder()
            let savedPlistData = try Data(contentsOf: url)
            self.items = try plistDecoder.decode(Set<HistoryItem>.self, from: savedPlistData)
        } catch {
            print(error)
        }
    }
    
    func add(id: String) {
        let newHistoryEntry = HistoryItem(id: id, bookmarkDate: Date())
        self.items.insert(newHistoryEntry)
        
        // save to plist file
        do {
            let plistEncoder = PropertyListEncoder()
            let plistData = try plistEncoder.encode(self.items)
            try plistData.write(to: url)
        } catch {
            print(error)
        }
        
        // add to the [Item] array
//        guard let newId = Int(id) else { return }
//        self.stories.append(Item(id: newId))
        
        // post notification to refresh the Stories Child View
        NotificationCenter.default.post(name: .historyAdded, object: nil)
    }
    
    func removeHistory() {
        self.items.removeAll()
        //self.stories = []
        
        // remove from plist file
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    func contains(id: String) -> Bool {
        return self.items.contains { $0.id == id }
    }
}


