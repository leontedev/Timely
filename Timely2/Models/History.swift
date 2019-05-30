//
//  History.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

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
  let url = FileManager.documentDirectoryURL.appendingPathComponent("history").appendingPathExtension("plist")
  
  var items: Set<HistoryItem> = []
  
  var sortedIds: [String] {
    let sortedSet = self.items.sorted(by: { $0.bookmarkDate > $1.bookmarkDate } )
    let sortedIds = sortedSet.map { $0.id }
    
    return sortedIds
  }
  
  
  private init() {
    // load previously saved Bookmarks from Documents / Bookmarks.plist
    do {
      let plistDecoder = PropertyListDecoder()
      let savedPlistData = try Data(contentsOf: url)
      self.items = try plistDecoder.decode(Set<HistoryItem>.self, from: savedPlistData)
    } catch {
      print(error)
    }
  }
  
  public func add(id: String) {
    let newHistoryEntry = HistoryItem(id: id, bookmarkDate: Date())
    self.items.insert(newHistoryEntry)

    // post notification to refresh the Stories Child View
    let userInfo: [String: String] = ["visitedItemID": id]
    NotificationCenter.default.post(name: .historyAdded, object: nil, userInfo: userInfo)
  }
  
  func remove(id: String, at indexPath: IndexPath?, from parentType: ParentStoriesChildViewController?) {
    
    self.items = self.items.filter { $0.id != id }

    if let indexPath = indexPath, let parentType = parentType {
      let userInfo: [String : Any] = ["indexPath": indexPath, "parentType": parentType]
      
      // post notification to refresh the Stories Child View
      NotificationCenter.default.post(name: .historyItemRemoved, object: nil, userInfo: userInfo)
    } else {
      NotificationCenter.default.post(name: .historyItemRemoved, object: nil)
    }
  }
  
  public func removeHistory() {
    self.items.removeAll()
  }
  
  public func contains(id: String) -> Bool {
    return self.items.contains { $0.id == id }
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


