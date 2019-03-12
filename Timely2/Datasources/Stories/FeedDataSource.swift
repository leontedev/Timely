//
//  FeedViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 12/21/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation
import UIKit

protocol FeedDataSourceDelegate: class {
    func didTapCell(feedURL: URLComponents, title: String, type: HNFeedType)
}

class FeedDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FeedDataSourceDelegate?
    var feed: [Feed] = []
    

    func setData(feedList: [Feed]){
        self.feed = feedList
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feed.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select Feed"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedCell
        
        cell.feedNameLabel.text = feed[indexPath.row].feedName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedURLstring = feed[indexPath.row].feedURL
        guard var feedURLComponents = URLComponents(string: feedURLstring) else {
            #warning("FeedList didSelectRowAt - when URL is malformed error message")
            //self.state = .error(HNError.badURL(fromString: feedURLstring))
            return
        }
        
        
        var feedName = feed[indexPath.row].feedName
        let feedType = feed[indexPath.row].feedType
        let currentTimestamp = Int(NSDate().timeIntervalSince1970)
        
        if feedType == .algolia {
            if let feedFromCalendarComponentByAdding = feed[indexPath.row].fromCalendarComponentByAdding {
                if let feedFromCalendarComponentValue = feed[indexPath.row].fromCalendarComponentValue {
                    
                    let today = Date()
                    let priorDate = Calendar.current.date(byAdding: feedFromCalendarComponentByAdding, value: feedFromCalendarComponentValue, to: today)
                    let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
                    
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                    
                    feedURLComponents.addOrModify(queryItemTimeRange)
                }
            } else {
                // feedID 8 is the "Since Last Visit" feed
                if feed[indexPath.row].feedID == 8 {
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
                        feedName = "Since " + validTime + " ago"
                    }
                    
                    feedURLComponents.addOrModify(queryItemTimeRange)
                }
            }
        }
        
        // Save the newly selected feed into Userdefaults (to load on next app open) if the default feed setting is set to "Previously Used"
        let feedID = feed[indexPath.row].feedID
        
        // It will return false if the key does not exist
        let isPreviouslySelectedFeed = UserDefaults.standard.bool(forKey: "isPreviouslySelectedFeed")
        
        // Overwrite the default feed if the "Previously Selected" setting was selected in the Defaults section of Settings
        if isPreviouslySelectedFeed {
            UserDefaults.standard.set(feedID, forKey: "initialFeedID")
        }
        
        self.delegate?.didTapCell(feedURL: feedURLComponents, title: feedName, type: feedType)
        
        if let feedURL = feedURLComponents.url {
            print(feedURL)
        }
    }
}


