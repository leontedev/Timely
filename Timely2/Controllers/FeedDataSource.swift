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
        let feedURL = URL(string: feedURLstring)!
        let feedName = feed[indexPath.row].feedName
        let feedType = feed[indexPath.row].feedType
        
        self.cellDelegate?.didTapCell(feedURL: feedURL, title: feedName, type: feedType)
    }
}


