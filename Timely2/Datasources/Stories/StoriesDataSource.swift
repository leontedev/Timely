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
    return self.algoliaStories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.reuseIdentifier, for: indexPath) as! StoryCell
    var itemID = ""
    
    updateStoryUI(forCell: cell)
    
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
    action.backgroundColor = Bookmarks.shared.contains(id: itemID) ? .red : .blue
    
    return action
  }
  
  func historyAction(at indexPath: IndexPath, for itemID: String) -> UIContextualAction {
    let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
      
      if History.shared.contains(id: itemID) {
        History.shared.remove(id: itemID, at: indexPath, from: self.parentType)
        
      } else {
        History.shared.add(id: itemID)
      }
      
      if self.parentType == .stories {
        self.delegate?.didUpdateRow(at: indexPath)
      }
      completion(true)
    }
    
    action.title = History.shared.contains(id: itemID) ? "Mark\nUnread" : "Mark\nRead"
    action.backgroundColor = History.shared.contains(id: itemID) ? .darkGray : .lightGray
    
    return action
  }
  
  
  // MARK: - Helper Functions
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
}
