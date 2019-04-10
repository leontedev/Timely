//
//  StoriesDataSource.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/1/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

protocol StoriesDataSourceDelegate: class {
    func didUpdateState(_ newState: State)
}

class StoriesDataSource: NSObject, UITableViewDataSource {
    
    weak var delegate: StoriesDataSourceDelegate?
    var currentSourceAPI: HNFeedType = .algolia
    var topStories: [Item] = []
    var algoliaStories: [AlgoliaItem] = []
    
    
    
    func setData(sourceAPI: HNFeedType, stories: [Item], algoliaStories: [AlgoliaItem]) {
        self.currentSourceAPI = sourceAPI
        self.topStories = stories
        self.algoliaStories = algoliaStories
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.currentSourceAPI {
        case .official:
            return self.topStories.count
        case .algolia:
            return self.algoliaStories.count
        }
    }
    

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.reuseIdentifier, for: indexPath) as! StoryCell
        
        
        switch self.currentSourceAPI {
            
        case .official:
            
            if self.topStories.indices.contains(indexPath.row) {
                let item = self.topStories[indexPath.row]
                
                if cell.accessoryView == nil {
                    let indicator = UIActivityIndicatorView(style: .gray)
                    cell.accessoryView = indicator
                }
                let indicator = cell.accessoryView as! UIActivityIndicatorView
                
                if let itemTitle = item.title {
                    cell.titleLabel?.text = itemTitle
                } else {
                    cell.titleLabel?.text = "Loading..."
                }
                
                if let itemURL = item.url?.host {
                    cell.urlLabel?.text = itemURL
                } else {
                    cell.urlLabel?.text = "Story ID: " + String(item.id)
                }
                
                
                if let itemDescendants = item.descendants {
                    cell.commentsCountLabel?.text = String(itemDescendants)
                } else {
                    cell.commentsCountLabel?.text = "-"
                }
                
                if let itemScore = item.score {
                    cell.upvotesCountLabel?.text = String(itemScore)
                } else {
                    cell.upvotesCountLabel?.text = "-"
                }
                
                if let epochTime = item.time {
                    // Display elapsed time
                    let componentsFormatter = DateComponentsFormatter()
                    componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                    componentsFormatter.maximumUnitCount = 1
                    componentsFormatter.unitsStyle = .abbreviated
                    
                    
                    let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                    cell.elapsedTimeLabel?.text = timeAgo
                } else {
                    cell.elapsedTimeLabel?.text = "-"
                }
                
                switch (item.state) {
                case .downloaded?:
                    indicator.stopAnimating()
                case .failed?:
                    indicator.stopAnimating()
                    cell.titleLabel?.text = "Failed to load"
                case .downloading?:
                    cell.titleLabel?.text = "Download in progress..."
                case .new?:
                    indicator.startAnimating()
                    //if !tableView.isDragging && !tableView.isDecelerating
                //startDownload(for: item, at: indexPath)
                case nil:
                    print("Error nil state to be displayed")
                }
            } else {
                self.delegate?.didUpdateState(.error(HNError.network("Invalid Response.")))
            }
            
        case .algolia:
            
            if self.algoliaStories.indices.contains(indexPath.row) {
                let item = self.algoliaStories[indexPath.row]
                
                if let itemTitle = item.title {
                    cell.titleLabel?.text = itemTitle
                } else {
                    cell.titleLabel?.text = "Loading..."
                }
                
                if let itemURL = item.url?.host {
                    cell.urlLabel?.text = itemURL.replacingOccurrences(of: "www.", with: "")
                }
                
                
                if let itemDescendants = item.num_comments {
                    cell.commentsCountLabel?.text = String(itemDescendants)
                } else {
                    cell.commentsCountLabel?.text = "-"
                }
                
                if let itemScore = item.points {
                    cell.upvotesCountLabel?.text = String(itemScore)
                } else {
                    cell.upvotesCountLabel?.text = "-"
                }
                
                let componentsFormatter = DateComponentsFormatter()
                componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                componentsFormatter.maximumUnitCount = 1
                componentsFormatter.unitsStyle = .abbreviated
                let timeAgo = componentsFormatter.string(from: item.created_at, to: Date())
                cell.elapsedTimeLabel?.text = timeAgo
            } else {
                //viewController.state = .error(HNError.network("Invalid Response."))
                self.delegate?.didUpdateState(.error(HNError.network("Invalid Response.")))
            }
            
        }
        
        return cell
    }
    
}
