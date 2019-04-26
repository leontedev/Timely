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
    func didUpdateRow(at indexPath: IndexPath)
}

class StoriesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: StoriesDataSourceDelegate?
    var currentSourceAPI: HNFeedType = .algolia
    var topStories: [Item] = []
    var algoliaStories: [AlgoliaItem] = []
    var parentType: ParentStoriesChildViewController?
    
    
    func setData(sourceAPI: HNFeedType, stories: [Item], algoliaStories: [AlgoliaItem], parentType: ParentStoriesChildViewController?) {
        self.currentSourceAPI = sourceAPI
        self.topStories = stories
        self.algoliaStories = algoliaStories
        self.parentType = parentType
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
    
    func updateVisitedStoryUI(forCell cell: StoryCell) {
        cell.titleLabel.textColor = .lightGray
        cell.commentsCountLabel.textColor = .lightGray
        cell.elapsedTimeLabel.textColor = .lightGray
        cell.upvotesCountLabel.textColor = .lightGray
        cell.commentsCountImage.alpha = CGFloat(0.3)
        cell.elapsedTimeImage.alpha = CGFloat(0.3)
        cell.upvotesCountImage.alpha = CGFloat(0.3)
        
        cell.bookmarkedTimeImage.alpha = CGFloat(0.3)
        cell.bookmarkedTimeLabel.textColor = .lightGray
    }
    
    func updateStoryUI(forCell cell: StoryCell) {
        cell.titleLabel.textColor = .black
        cell.commentsCountLabel.textColor = .black
        cell.elapsedTimeLabel.textColor = .black
        cell.upvotesCountLabel.textColor = .black
        cell.commentsCountImage.alpha = CGFloat(1)
        cell.elapsedTimeImage.alpha = CGFloat(1)
        cell.upvotesCountImage.alpha = CGFloat(1)
        
        cell.bookmarkedTimeImage.alpha = CGFloat(1)
        cell.bookmarkedTimeLabel.textColor = .black
        
        cell.bookmarkedTimeImage.isHidden = true
        cell.bookmarkedTimeLabel.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.reuseIdentifier, for: indexPath) as! StoryCell
        var itemID = ""
        
        updateStoryUI(forCell: cell)
        
        switch self.currentSourceAPI {
        case .official:
            
            if self.topStories.indices.contains(indexPath.row) {
                let item = self.topStories[indexPath.row]
                itemID = String(item.id)
                
                
                if cell.accessoryView == nil {
                    let indicator = UIActivityIndicatorView(style: .gray)
                    cell.accessoryView = indicator
                }
                let indicator = cell.accessoryView as! UIActivityIndicatorView
                
                if let itemTitle = item.title {
                    cell.titleLabel?.text = itemTitle
                }
                
                if let itemURL = item.url?.host {
                    cell.urlLabel?.text = itemURL
                }
                
                
                if let itemDescendants = item.descendants {
                    cell.commentsCountLabel?.text = String(itemDescendants)
                }
                
                if let itemScore = item.score {
                    cell.upvotesCountLabel?.text = String(itemScore)
                }
                
                if let epochTime = item.time {
                    // Display elapsed time
                    let componentsFormatter = DateComponentsFormatter()
                    componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                    componentsFormatter.maximumUnitCount = 1
                    componentsFormatter.unitsStyle = .abbreviated
                    
                    
                    let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                    cell.elapsedTimeLabel?.text = timeAgo
                }
                
                switch (item.state) {
                case .downloaded?:
                    indicator.stopAnimating()
                case .failed?:
                    indicator.stopAnimating()
                    cell.titleLabel?.text = "Failed to load"
                case .downloading?:
                    cell.titleLabel?.text = "Downloading story..."
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
                itemID = item.objectID
                
                
                if let itemTitle = item.title {
                    cell.titleLabel?.text = itemTitle
                }
                
                if let itemURL = item.url?.host {
                    cell.urlLabel?.text = itemURL.replacingOccurrences(of: "www.", with: "")
                }
                
                
                if let itemDescendants = item.num_comments {
                    cell.commentsCountLabel?.text = String(itemDescendants)
                }
                
                if let itemScore = item.points {
                    cell.upvotesCountLabel?.text = String(itemScore)
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
        
        // Check if this is the Stories View (and not Bookmarks or History) and that the story was already visited
        if let parentType = parentType {
            if parentType == .stories && History.shared.contains(id: itemID) {
                updateVisitedStoryUI(forCell: cell)
            }
        }
        
        // Check if the story was bookmarked
        if Bookmarks.shared.contains(id: itemID) {
            
            cell.bookmarkedTimeImage.isHidden = false
            
            // Display elapsed time
            let bookmarkTime = Bookmarks.shared.bookmarkDate(for: itemID)
            
            let componentsFormatter = DateComponentsFormatter()
            componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
            componentsFormatter.maximumUnitCount = 1
            componentsFormatter.unitsStyle = .abbreviated
            
            
            let timeAgo = componentsFormatter.string(from: bookmarkTime, to: Date())
            cell.bookmarkedTimeLabel.text = timeAgo
            cell.bookmarkedTimeLabel.isHidden = false
        }
        
        return cell
    }
    
    //MARK: - Delegates
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // get the Item ID string
        var itemID = ""
        switch self.currentSourceAPI {
        case .official:
            if self.topStories.indices.contains(indexPath.row) {
                let item = self.topStories[indexPath.row]
                itemID = String(item.id)
            }
        case .algolia:
            if self.algoliaStories.indices.contains(indexPath.row) {
                let item = self.algoliaStories[indexPath.row]
                itemID = item.objectID
            }
        }
        
        // set up the actions
        let bookmark = bookmarkAction(at: indexPath, for: itemID)
        let history = historyAction(at: indexPath, for: itemID)
        
        // first item from the array is actually first from the right on the trailing swipe menu
        return UISwipeActionsConfiguration(actions: [history, bookmark])
    }
    
    func bookmarkAction(at indexPath: IndexPath, for itemID: String) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in

            if Bookmarks.shared.contains(id: itemID) {
                Bookmarks.shared.remove(id: itemID)
            } else {
                Bookmarks.shared.add(id: itemID)
            }
            
            self.delegate?.didUpdateRow(at: indexPath)
            completion(true)
        }
        
        action.image = UIImage(named: "icn_bookmarked")
        action.backgroundColor = Bookmarks.shared.contains(id: itemID) ? .red : .blue
        
        return action
    }
    
    func historyAction(at indexPath: IndexPath, for itemID: String) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            
            if !History.shared.contains(id: itemID) {
                History.shared.add(id: itemID)
            }
            
            self.delegate?.didUpdateRow(at: indexPath)
            completion(true)
        }
        action.title = "Mark\nRead"
        action.backgroundColor = .lightGray
        
        return action
    }
}
