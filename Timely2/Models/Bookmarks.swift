//
//  Bookmark.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/29/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation


public struct Bookmark: Codable {
  public let id: String
  public let bookmarkDate: Date
}


public class Bookmarks {
  static let shared = Bookmarks()
  let url = FileManager.documentDirectoryURL.appendingPathComponent("bookmarks").appendingPathExtension("plist")
  
  var items: [Bookmark] = []
  var sortedIds: [String] {
    let sortedSet = self.items.sorted(by: { $0.bookmarkDate > $1.bookmarkDate } )
    let sortedIds = sortedSet.map { $0.id }
    
    return sortedIds
  }
  
  
  private init() {
    // load previously saved Bookmarks from Documents / Bookmarks.plist
    do {
      //print(FileManager.documentDirectoryURL.path)
      let plistDecoder = PropertyListDecoder()
      let savedPlistData = try Data(contentsOf: url)
      self.items = try plistDecoder.decode([Bookmark].self, from: savedPlistData)
    } catch {
      print(error)
    }
  }
  
  func add(id: String) {
    let newBookmark = Bookmark(id: id, bookmarkDate: Date())
    self.items.append(newBookmark)
    
    // post notification to refresh the Stories Child View
    NotificationCenter.default.post(name: .bookmarkAdded, object: nil)
  }
  
  func remove(id: String) {
    self.items = self.items.filter { $0.id != id }
    
    // post notification to refresh the Stories Child View
    NotificationCenter.default.post(name: .bookmarkRemoved, object: nil)
  }
  
  func contains(id: String) -> Bool {
    return self.items.contains { $0.id == id }
  }
  
  func bookmarkDate(for id: String) -> Date {
    let story = self.items.filter { $0.id == id }
    return story[0].bookmarkDate
  }
  
  public func persistData() {
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
  }
}
