import Foundation

//import os

//let viewcycle = OSLog(subsystem: "com.mihaileonte.timely", category: "ViewCycle")
//let fileOperationsLog = OSLog(subsystem: "com.mihaileonte.timely", category: "FileOperations")




public struct Bookmark: Codable {
    public let id: String
    public let bookmarkDate: Date
}

let a = Bookmark(id: "1", bookmarkDate: Date())
a.id
a.bookmarkDate
let bookmarkz = [a, Bookmark(id: "2", bookmarkDate: Date())]

do {
    let bookmarkURL = FileManager.documentDirectoryURL.appendingPathComponent("bookmarks").appendingPathExtension("plist")

    let plistEncoder = PropertyListEncoder()
    let plistData = try plistEncoder.encode(bookmarkz)
    try plistData.write(to: bookmarkURL)

    let plistDecoder = PropertyListDecoder()
    let savedPlistData = try Data(contentsOf: bookmarkURL)
    let decodedPlist = try plistDecoder.decode([Bookmark].self, from: savedPlistData)
    print(decodedPlist)

} catch { print(error) }



// the Documents directory URL
extension FileManager {
    static var documentDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

public class Bookmarks {
    static let shared = Bookmarks()
    var items: [Bookmark] = []
    let url = FileManager.documentDirectoryURL.appendingPathComponent("bookmarks").appendingPathExtension("plist")
    
    private init() {
        // load previously saved Bookmarks from Documents / Bookmarks.plist
        do {
            let plistDecoder = PropertyListDecoder()
            let savedPlistData = try Data(contentsOf: url)
            self.items = try plistDecoder.decode([Bookmark].self, from: savedPlistData)
        } catch { }
    }
    
    func add(id: String) {
        let newBookmark = Bookmark(id: id, bookmarkDate: Date())
        self.items.append(newBookmark)
        
        // save to plist file
        do {
            let plistEncoder = PropertyListEncoder()
            let plistData = try plistEncoder.encode(newBookmark)
            try plistData.write(to: url)
        } catch { }
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
        } catch { }
    }
    
    func contains(id: String) -> Bool {
        return self.items.contains { $0.id == id }
    }
}

Bookmarks.shared.items
Bookmarks.shared.add(id: "3")
Bookmarks.shared.add(id: "4")

let componentsFormatter = DateComponentsFormatter()
componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
componentsFormatter.maximumUnitCount = 1
componentsFormatter.unitsStyle = .abbreviated
let timeAgo = componentsFormatter.string(from: Bookmarks.shared.items[0].bookmarkDate, to: Date())


//// the Documents directory's path
////os_log("Initial Load of Bookmarks Completed", log: viewcycle, type: .info)
//
////os_signpost(.begin, log: fileOperationsLog, name: "Bookmarks() init")
////let myBookmarks = Bookmarks()
////os_signpost(.end, log: fileOperationsLog, name: "Bookmarks() init")

