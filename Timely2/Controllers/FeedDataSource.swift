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
    func didTapCell(feedURL: URL, title: String, type: HNFeedType)
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedCell
        
        cell.feedNameLabel.text = feed[indexPath.row].feedName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedURLstring = feed[indexPath.row].feedURL
        var feedURLComponents = URLComponents(string: feedURLstring)
        let feedName = feed[indexPath.row].feedName
        let feedType = feed[indexPath.row].feedType
        
        if feedType == .algolia {
            if let feedFromCalendarComponentByAdding = feed[indexPath.row].fromCalendarComponentByAdding {
                if let feedFromCalendarComponentValue = feed[indexPath.row].fromCalendarComponentValue {
                    let currentTimestamp = Int(NSDate().timeIntervalSince1970)
                    let today = Date()
                    let priorDate = Calendar.current.date(byAdding: feedFromCalendarComponentByAdding, value: feedFromCalendarComponentValue, to: today)
                    let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
                    
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                    feedURLComponents?.queryItems?.append(queryItemTimeRange)
                    
                }
            }
        }
        
        if let feedURL = feedURLComponents?.url {
            print(feedURL)
            self.cellDelegate?.didTapCell(feedURL: feedURL, title: feedName, type: feedType)
        }
    }
}


