//
//  FeedViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 12/21/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import Foundation
import UIKit

protocol CellFeedProtocol {
    func didTapCell(feedURL: URLComponents, title: String, type: HNFeedType)
}

class FeedDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var feed: [Feed] = []
    var cellDelegate: CellFeedProtocol?

    
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
        
        
        let feedName = feed[indexPath.row].feedName
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
                    
                    feedURLComponents.addOrModify(queryItemTimeRange)
                }
            }
        }
        
        //Save the newly selected feed into Userdefaults (to load on next app open)
        let feedID = feed[indexPath.row].feedID
        UserDefaults.standard.set(feedID, forKey: "feedID")
        //Save the current timestamp to be used in the "Since Last Visit" feed
        UserDefaults.standard.set(currentTimestamp, forKey: "lastFeedLoadTimestamp")
        

        self.cellDelegate?.didTapCell(feedURL: feedURLComponents, title: feedName, type: feedType)
        
        if let feedURL = feedURLComponents.url {
            print(feedURL)
        }
    }
}


