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

public struct HistoryItem: Codable {
    public let id: String
    public let bookmarkDate: Date
}


public class History {
    static let shared = History()
    var items: [HistoryItem] = []
    var stories: [Item] = []
    let url = FileManager.documentDirectoryURL.appendingPathComponent("history").appendingPathExtension("plist")
    
    private init() {
        // load previously saved Bookmarks from Documents / Bookmarks.plist
        do {
            print(FileManager.documentDirectoryURL.path)
            let plistDecoder = PropertyListDecoder()
            let savedPlistData = try Data(contentsOf: url)
            self.items = try plistDecoder.decode([HistoryItem].self, from: savedPlistData)
            for item in self.items {
                guard let id = Int(item.id) else { continue }
                stories.append(Item(id: id))
            }
        } catch {
            print(error)
        }
    }
    
    func add(id: String) {
        let newHistoryEntry = HistoryItem(id: id, bookmarkDate: Date())
        self.items.append(newHistoryEntry)
        
        // save to plist file
        do {
            let plistEncoder = PropertyListEncoder()
            let plistData = try plistEncoder.encode(self.items)
            try plistData.write(to: url)
        } catch {
            print(error)
        }
        
        // add to the [Item] array
        guard let newId = Int(id) else { return }
        self.stories.append(Item(id: newId))
        
        // post notification to refresh the Stories Child View
        NotificationCenter.default.post(name: .historyAdded, object: nil)
    }
    
    func removeHistory() {
        self.items = []
        
        // remove from plist file
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
        } catch {
            print(error)
        }
        
        // remove from the [Item] array
//        guard let newId = Int(id) else { return }
//        self.stories = self.stories.filter { $0.id != newId }
        
    }
    
    func contains(id: String) -> Bool {
        return self.items.contains { $0.id == id }
    }
}
