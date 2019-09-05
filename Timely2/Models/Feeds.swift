//
//  Feeds.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/9/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//



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
    
    var selectedFeed: Feed {
        didSet {
            UserDefaults.standard.set(selectedFeed.feedID, forKey: "initialFeedID")
            isSetPreviouslySelectedFeed = false
            defaultFeedDescription = selectedFeed.feedName
        }
    }
    
    // obtain a refreshed URL each time it is needed (as for algolia the timestamps will change)
    var selectedFeedURLComponents: URLComponents? {
        get {
            guard var selectedFeedURL = URLComponents(string: selectedFeed.feedURL) else { return nil }

            let currentTimestamp = Int(NSDate().timeIntervalSince1970)
            
            if selectedFeed.feedType == .algolia {
                if let feedFromCalendarComponentByAdding = selectedFeed.fromCalendarComponentByAdding {
                    if let feedFromCalendarComponentValue = selectedFeed.fromCalendarComponentValue {
                        
                        let today = Date()
                        let priorDate = Calendar.current.date(byAdding: feedFromCalendarComponentByAdding, value: feedFromCalendarComponentValue, to: today)
                        let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
                        
                        let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                        
                        selectedFeedURL.addOrModify(queryItemTimeRange)
                    }
                    
                // Timely SmartFeed
                } else if selectedFeed.feedID == 10 {
                    
                    var priorTimestamp = UserDefaults.standard.integer(forKey: "backhistoryStartDate")
                    
                    // Defaults should set the default, but it might not execute in time?
                    if priorTimestamp == 0 {
                        print("DEFAULTS self.setBackhistory(at: .threeMonths) WAS NOT EXECUTED")
                        Defaults.shared.setBackhistory(at: .threeMonths)
                        priorTimestamp = UserDefaults.standard.integer(forKey: "backhistoryStartDate")
                    }
                        
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                    
                    selectedFeedURL.addOrModify(queryItemTimeRange)
                    
                    
                // Since Last Visit Feed
                } else if selectedFeed.feedID == 8 {
                    var sinceTimestamp = UserDefaults.standard.integer(forKey: "lastFeedLoadTimestamp")
                    
                    //it will return 0 if it was never saved previously
                    if sinceTimestamp == 0 {
                        sinceTimestamp = currentTimestamp
                    }
                    
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(sinceTimestamp),created_at_i<\(currentTimestamp)")
                    
                    // Display elapsed time in the Feed Title, eg: Since Last Visit - 2h ago
                    let componentsFormatter = DateComponentsFormatter()
                    componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                    componentsFormatter.maximumUnitCount = 1
                    componentsFormatter.unitsStyle = .abbreviated
                    
                    let epochTime = Date(timeIntervalSince1970: TimeInterval(sinceTimestamp))
                    let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                    
                    if let validTime = timeAgo {
                        //feedName = "Since " + validTime + " ago"
                        // Update Since Last Visit name
                        //self.feeds[selectedFeed.feedID].feedName = "Since " + validTime + " ago"
                    }
                    
                    selectedFeedURL.addOrModify(queryItemTimeRange)
                }
            }
            
            return selectedFeedURL
        }
    }
    
    // Default Feed setting Name - eg: Previously Selected, or HN Last 24h
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
    
    func updateSelectedFeed(for index: Int) {
        self.selectedFeed = self.feeds[index]
        let feedID = self.selectedFeed.feedID
        
        // Save the newly selected feed into Userdefaults (to load on next app open) if the default feed setting is set to "Previously Used"
        
        // It will return false if the key does not exist
        let isPreviouslySelectedFeed = UserDefaults.standard.bool(forKey: "isPreviouslySelectedFeed")
        
        // Overwrite the default feed if the "Previously Selected" setting was selected in the Defaults section of Settings
        if isPreviouslySelectedFeed {
            UserDefaults.standard.set(feedID, forKey: "initialFeedID")
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
        
        // ignore the Feeds flagged .isHidden = true
        self.feeds = self.feeds.filter { $0.isHidden == false }

        
        /// Load The Previously Selected Feed ID from Userdefaults and update timestamps for feed URLs
        var feedID = UserDefaults.standard.integer(forKey: "initialFeedID")
        
        //defaults.integer(forKey: "initialFeedID") will return 0 if the value is not found
        if feedID == 0 {
            // automatically select the default feed if the setting was never changed by the user: "Last 24h"
            feedID = 2
        } else if feedID == 8 {
            // Since Last Visit - rename the feed
            
        }

        selectedFeed = feeds.filter { $0.feedID == feedID }[0]
        
        self.defaultFeedDescription = isSetPreviouslySelectedFeed ? "Previously Selected" : selectedFeed.feedName
    }
    
}
