//
//  History.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

public struct HistoryItem: Codable, Hashable, Equatable {
    
    public let id: String
    public var stateChangedDate: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.id == rhs.id
    }
}

//  String raw values are implicitly assigned, eg: new is encoded to "new" etc.
public enum StoryState: String, Codable {
    case new
    case seen
    case read
}


public class History {
    static let shared = History()
    let readItemsURL = FileManager.documentDirectoryURL.appendingPathComponent("history").appendingPathExtension("plist")
    let seenItemsURL = FileManager.documentDirectoryURL.appendingPathComponent("history_seen").appendingPathExtension("plist")
    
    var readItems: Set<HistoryItem> = []
    var seenItems: Set<HistoryItem> = []
    
    // returns the read items sorted based on date added
    var sortedIds: [String] {
        let sortedSet = self.readItems.sorted(by: { $0.stateChangedDate > $1.stateChangedDate } )
        let sortedIds = sortedSet.map { $0.id }
        
        return sortedIds
    }
    
    
    private init() {
        // load previously saved Historyread & seen items from Documents / history.plist & history_seen.plist
        do {
            let plistDecoder = PropertyListDecoder()
            
            var savedPlistData = try Data(contentsOf: readItemsURL)
            self.readItems = try plistDecoder.decode(Set<HistoryItem>.self, from: savedPlistData)
            
            savedPlistData = try Data(contentsOf: seenItemsURL)
            self.seenItems = try plistDecoder.decode(Set<HistoryItem>.self, from: savedPlistData)
        } catch {
            print(error)
        }
    }
    
    public func add(id: String, withState state: StoryState) {
        
        if state == .seen {
            // Add it only if no Read & Seen state was already registered for the id
            // We don't have to check if the item exists in the Set, insert() will simply return false
            //if !contains(id) {
            let newSeenHistoryEntry = HistoryItem(id: id, stateChangedDate: Date())
            self.seenItems.insert(newSeenHistoryEntry)
        } else if state == .read {      //&& !contains(id, withState: .read) {
            
            let newReadHistoryEntry = HistoryItem(id: id, stateChangedDate: Date())
            self.readItems.insert(newReadHistoryEntry)
            
            // post notification to refresh the Stories Child View for the History tab
            let userInfo: [String: String] = ["visitedItemID": id]
            NotificationCenter.default.post(name: .historyAdded, object: nil, userInfo: userInfo)
            
            // Below implementation for Array instead of Set
            // if no seen state was registered earlier, we add the new read state, otherwise we modify the state from .seen to .read
//            if !contains(id, withState: .seen) {
//                let newHistoryItem = HistoryItem(id: id, state: state, stateChangedDate: Date())
//                self.readItems.append(newHistoryItem)
//            } else {
//                if let index = self.readItems.firstIndex(where: { $0.id == id }) {
//                    self.readItems[index].state = .read
//                }
//            }
            
            
        }
        
        persistData()
        
    }
    
    func remove(id: String, at indexPath: IndexPath?, from parentType: ParentStoriesChildViewController?) {
        
        self.readItems = self.readItems.filter { $0.id != id }
        
        if let indexPath = indexPath, let parentType = parentType {
            
            let userInfo: [String : Any] = ["indexPath": indexPath, "parentType": parentType]
            
            // post notification to refresh the Stories Child View
            NotificationCenter.default.post(name: .historyItemRemoved, object: nil, userInfo: userInfo)
            
        } else {
            NotificationCenter.default.post(name: .historyItemRemoved, object: nil)
        }
        
        persistData()
    }
    
    public func removeHistory() {
        self.readItems.removeAll()
        persistData()
    }
    
    public func contains(_ id: String) -> Bool {
        if self.readItems.contains(where: { $0.id == id }) {
            return true
        } else {
            return self.seenItems.contains { $0.id == id }
        }
    }
    
    public func contains(_ id: String, withState state: StoryState) -> Bool {
        if state == .read {
            return self.readItems.contains { $0.id == id }
        } else if state == .seen {
            return self.seenItems.contains { $0.id == id }
        } else {
            return false
        }
    }
    
    public func persistData() {
        do {
            // Write Read Items to disk
            if FileManager.default.fileExists(atPath: readItemsURL.path) {
                try FileManager.default.removeItem(atPath: readItemsURL.path)
            }
            let plistEncoder = PropertyListEncoder()
            var plistData = try plistEncoder.encode(self.readItems)
            try plistData.write(to: readItemsURL)
            
            // Write Seen Items to disk
            if FileManager.default.fileExists(atPath: seenItemsURL.path) {
                try FileManager.default.removeItem(atPath: seenItemsURL.path)
            }
            
            plistData = try plistEncoder.encode(self.seenItems)
            try plistData.write(to: seenItemsURL)
            
        } catch {
            print(error)
        }
    }
}


