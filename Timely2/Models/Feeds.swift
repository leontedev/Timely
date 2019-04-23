//
//  Feeds.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/9/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

extension Calendar.Component: Decodable {
    public init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label {
        case "calendar": self = .calendar
        case "day": self = .day
        case "era": self = .era
        case "hour": self = .hour
        case "minute": self = .minute
        case "month": self = .month
        case "nanosecond": self = .nanosecond
        case "quarter": self = .quarter
        case "second": self = .second
        case "timeZone": self = .timeZone
        case "weekOfMonth": self = .weekOfMonth
        case "weekOfYear": self = .weekOfYear
        case "weekday": self = .weekday
        case "weekdayOrdinal": self = .weekdayOrdinal
        case "year": self = .year
        case "yearForWeekOfYear": self = .yearForWeekOfYear
        default: self = .day
        }
    }
}

enum HNFeedType: String, Decodable {
    case official = "official"
    case algolia = "algolia"
}

struct Feed: Decodable {
    var feedID: Int8
    var feedName: String
    var feedURL: String
    var feedType: HNFeedType
    var fromCalendarComponentByAdding: Calendar.Component?
    var fromCalendarComponentValue: Int?
    var isHidden: Bool
}


public class Feeds {
    static let shared = Feeds()
    
    var feeds: [Feed] = []
    var selectedFeedURLComponents: URLComponents = URLComponents()
    
    // Default Feed setting - eg: Previously Selected, or HN Last 24h
    var defaultFeedDescription: String = ""
    
    // initially, if userdefaults is not set, it will return 0
    var isSetPreviouslySelectedFeed: Bool = UserDefaults.standard.bool(forKey: "isPreviouslySelectedFeed") {
        didSet {
            UserDefaults.standard.set(isSetPreviouslySelectedFeed, forKey: "isPreviouslySelectedFeed")
            if isSetPreviouslySelectedFeed {
                defaultFeedDescription = "Previously Selected"
            }
        }
    }
    
    var selectedFeed: Feed {
        didSet {
            UserDefaults.standard.set(selectedFeed.feedID, forKey: "initialFeedID")
            isSetPreviouslySelectedFeed = false
            defaultFeedDescription = selectedFeed.feedName
        }
    }
    
    
    private init() {
        
        /// Loads Feed data from FeedList.plist and parses it in an array of Feed type.
        if let feedListURL = Bundle.main.url(forResource: "FeedList", withExtension: "plist") {
            do {
                let feedListData = try Data(contentsOf: feedListURL)
                let plistDecoder = PropertyListDecoder()
                self.feeds = try plistDecoder.decode([Feed].self, from: feedListData)
            } catch {
                print(error)
                
            }
        }
        self.feeds = self.feeds.filter { $0.isHidden == false }

        
        /// Load The Previously Selected Feed ID from Userdefaults and update timestamps for feed URLs
        var feedID = UserDefaults.standard.integer(forKey: "initialFeedID")
        
        //defaults.integer(forKey: "initialFeedID") will return 0 if the value is not found
        if feedID == 0 {
            // automatically select the default feed if the setting was never changed by the user: "Last 24h"
            feedID = 2
        }

        selectedFeed = feeds.filter { $0.feedID == feedID }[0]
    
        guard var feedURLComponents = URLComponents(string: selectedFeed.feedURL) else {
            return
        }
        
        selectedFeedURLComponents = feedURLComponents
        
        if selectedFeed.feedType == .algolia {
            if let feedFromCalendarComponentByAdding = selectedFeed.fromCalendarComponentByAdding {
                if let feedFromCalendarComponentValue = selectedFeed.fromCalendarComponentValue {
                    let currentTimestamp = Int(NSDate().timeIntervalSince1970)
                    let today = Date()
                    let priorDate = Calendar.current.date(byAdding: feedFromCalendarComponentByAdding, value: feedFromCalendarComponentValue, to: today)
                    let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
                    
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                    
                    selectedFeedURLComponents.addOrModify(queryItemTimeRange)
                }
            }
        }
        
        defaultFeedDescription = isSetPreviouslySelectedFeed ? "Previously Selected" : selectedFeed.feedName

        
    }
    
}
