//
//  Bookmark.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/29/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

// the Documents directory URL
extension FileManager {
    static var documentDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

public struct Bookmark: Codable {
    public let id: String
    public let bookmarkDate: Date
}


public class Bookmarks {
    static let shared = Bookmarks()
    var items: [Bookmark] = []
    var stories: [Item] = []
    let url = FileManager.documentDirectoryURL.appendingPathComponent("bookmarks").appendingPathExtension("plist")
    
    private init() {
        // load previously saved Bookmarks from Documents / Bookmarks.plist
        do {
            print(FileManager.documentDirectoryURL.path)
            let plistDecoder = PropertyListDecoder()
            let savedPlistData = try Data(contentsOf: url)
            self.items = try plistDecoder.decode([Bookmark].self, from: savedPlistData)
            for item in self.items {
                guard let id = Int(item.id) else { continue }
                stories.append(Item(id: id))
            }
        } catch {
            print(error)
        }
    }
    
    func add(id: String) {
        let newBookmark = Bookmark(id: id, bookmarkDate: Date())
        self.items.append(newBookmark)
        
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
    }
    
    func remove(id: String) {
        self.items = self.items.filter { $0.id != id }
        
        // remove from plist file
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
            let plistEncoder = PropertyListEncoder()
            let plistData = try plistEncoder.encode(self.items)
            try plistData.write(to: url)
        } catch {
            print(error)
        }
        
        // remove from the [Item] array
        guard let newId = Int(id) else { return }
        self.stories = self.stories.filter { $0.id != newId }
    }
    
    func contains(id: String) -> Bool {
        return self.items.contains { $0.id == id }
    }
}
