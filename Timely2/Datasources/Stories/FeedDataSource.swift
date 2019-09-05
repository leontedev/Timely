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
    func didTapCell(feedURL: URLComponents, title: String, type: HNFeedType, id: Int8)
}

class FeedDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FeedDataSourceDelegate?
    // var feed: [Feed] = []
    
// Not required as the Feeds.shared singleton is used
//    func update(feedList: [Feed]){
//        self.feed = feedList
//    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Feeds.shared.feeds.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select Feed"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedCell
        cell.feedNameLabel.text = Feeds.shared.feeds[indexPath.row].feedName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedID  = Feeds.shared.feeds[indexPath.row].feedID
        
        // update Feeds.shared.selectedFeed 
        Feeds.shared.updateSelectedFeed(for: indexPath.row)
        
        // obtain a re-made URL
        guard let feedURLComponents = Feeds.shared.selectedFeedURLComponents else { return }
        
        let feedName = Feeds.shared.feeds[indexPath.row].feedName
        let feedType = Feeds.shared.feeds[indexPath.row].feedType
        
        
        self.delegate?.didTapCell(feedURL: feedURLComponents, title: feedName, type: feedType, id: feedID)
        
    }
}


