//
//  NotificationName.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/17/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    // Bookmarks
    
    static var bookmarkAdded: Notification.Name {
        return .init(rawValue: "Bookmarks.addedNewId")
    }
    
    
    static var bookmarkRemoved: Notification.Name {
        return .init(rawValue: "Bookmarks.removedId")
    }

    // History
    
    static var historyAdded: Notification.Name {
        return .init(rawValue: "History.addedNewId")
    }
    
    static var historyItemRemoved: Notification.Name {
        return .init(rawValue: "History.removedId")
    }
    
    static var historyCleared: Notification.Name {
        return .init(rawValue: "History.clearAll")
    }
    
    // Settings / Change Default Font Size
    
    // to update continuously the font size of the label storiesSystemFontLabel: "Use System Font Size" in this View
    static var storiesLabelAppearanceChanged: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.storiesLabelAppearanceChanged")
    }
    
    // to update the Stories ItemCell font size, once, after the stories slider is released with the final value
    static var storiesLabelAppearanceChangingFinished: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.storiesLabelAppearanceChangingFinished")
    }
    
    // to update continuously the font size of the label commentsSystemFontLabel: "Use System Font Size" in this View
    static var commentsLabelAppearanceChanged: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.commentsLabelAppearanceChanged")
    }
    
    // to update the Comments attributed string, once, after the comments slider is released with the final value
    static var commentsLabelAppearanceChangingFinished: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.commentsLabelAppearanceChangingFinished")
    }
    
}

