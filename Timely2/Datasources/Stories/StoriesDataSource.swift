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
    var algoliaStories: [Story] = []
    var parentType: ParentStoriesChildViewController?
    
    
    func update(algoliaStories: [Story], parentType: ParentStoriesChildViewController?) {
        self.algoliaStories = algoliaStories
        self.parentType = parentType
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.algoliaStories.count > 0 {
//            return self.algoliaStories.count + 100
//        }

        return self.algoliaStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.reuseIdentifier, for: indexPath) as! StoryCell
        var itemID = ""
        

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
            self.delegate?.didUpdateState(.error(HackerNewsError.invalidData))
        }
        
        
        if let parentType = parentType {
            if parentType == .stories {
                if History.shared.contains(itemID, withState: .read) {
                    updateStoryUI(on: cell, forState: .read)
                } else if History.shared.contains(itemID, withState: .seen) {
                    updateStoryUI(on: cell, forState: .seen)
                } else {
                    updateStoryUI(on: cell, forState: .new)
                }
            // Bookmarks and History UI
            } else {
                updateStoryUI(on: cell, forState: .seen)
            }
        } else {
            updateStoryUI(on: cell, forState: .new)
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
    
    // Mark stories as seen
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        let previousvVerticalContentOffset = verticalContentOffset
//        verticalContentOffset  = tableView.contentOffset.y
//
//        let differenceOffset = verticalContentOffset - previousvVerticalContentOffset
//
//        if differenceOffset > 60 {
//
//            if self.algoliaStories.indices.contains(indexPath.row) {
//                History.shared.add(id: self.algoliaStories[indexPath.row].objectID, withState: .seen)
//            } else {
//                print("indexPath \(indexPath) from \(self.algoliaStories.count) (self.algoliaStories.count)")
//            }
//        }
        
        // We want to mark as seen only the stories which are scrolled over the top, and ignore the ones which are scrolled to the bottom. So we will compare the indexPath of the stories which were scrolled off with the indexPath of the firstVisible cell.
        guard let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first else { return }
        
        if indexPath.row < firstVisibleIndexPath.row {
            // This cell has been scrolled off the top of the table view
            History.shared.add(id: self.algoliaStories[indexPath.row].objectID, withState: .seen)
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // get the Item ID string
        var itemID = ""
        
        if self.algoliaStories.indices.contains(indexPath.row) {
            let item = self.algoliaStories[indexPath.row]
            itemID = item.objectID
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
            
            if self.parentType == .stories {
                self.delegate?.didUpdateRow(at: indexPath)
            }
            completion(true)
        }
        
        action.image = UIImage(named: "icn_bookmarked")
        action.backgroundColor = Bookmarks.shared.contains(id: itemID) ? UIColor(named: "RemoveBookmarkAction") : UIColor(named: "BookmarkAction")
        
        return action
    }
    
    func historyAction(at indexPath: IndexPath, for itemID: String) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            
            if History.shared.contains(itemID, withState: .read) {
                History.shared.remove(id: itemID, at: indexPath, from: self.parentType)
                
            } else {
                History.shared.add(id: itemID, withState: .read)
            }
            
            if self.parentType == .stories {
                self.delegate?.didUpdateRow(at: indexPath)
            }
            completion(true)
        }
        
        action.title = History.shared.contains(itemID, withState: .read) ? "Mark\nUnread" : "Mark\nRead"
        action.backgroundColor = History.shared.contains(itemID, withState: .read) ? .darkGray : .lightGray
        
        return action
    }
    
    func seenAction(at indexPath: IndexPath, for itemID: String) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            
            if History.shared.contains(itemID, withState: .seen) {
                History.shared.remove(id: itemID, at: indexPath, from: self.parentType)
                
            } else {
                History.shared.add(id: itemID, withState: .read)
            }
            
            if self.parentType == .stories {
                self.delegate?.didUpdateRow(at: indexPath)
            }
            completion(true)
        }
        
        action.title = History.shared.contains(itemID, withState: .read) ? "Mark\nUnread" : "Mark\nRead"
        action.backgroundColor = History.shared.contains(itemID, withState: .read) ? .darkGray : .lightGray
        
        return action
    }
    
    
    // MARK: - Helper Functions
    
    // Set Appearance for Stories (New unread, seen or read/opened)
    func updateStoryUI(on cell: StoryCell, forState state: StoryState) {
        
        switch state {
        case .new:
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
            
            // Show the orange cicle marking new stories
            cell.newStoryCircleView.isHidden = false
            
            
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
        case .seen:
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            
            // Hide the orange cicle marking new stories
            cell.newStoryCircleView.isHidden = true
            
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
        case .read:
            cell.titleLabel.textColor = .lightGray
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            
            // Hide the orange cicle marking new stories
            cell.newStoryCircleView.isHidden = true
            
            cell.commentsCountLabel.textColor = .lightGray
            cell.elapsedTimeLabel.textColor = .lightGray
            cell.upvotesCountLabel.textColor = .lightGray
            
            cell.commentsCountImage.alpha = CGFloat(0.3)
            cell.elapsedTimeImage.alpha = CGFloat(0.3)
            cell.upvotesCountImage.alpha = CGFloat(0.3)
            
            cell.bookmarkedTimeImage.alpha = CGFloat(0.3)
            cell.bookmarkedTimeLabel.textColor = .lightGray
        }
        
        
    }
}


