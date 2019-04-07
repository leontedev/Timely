//
//  StoriesViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/7/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController {
    
    @IBOutlet weak var headerTitle: UINavigationItem!
    
    // Feed Selection View Outlets
    @IBOutlet weak var feedButton: UIBarButtonItem!
    @IBOutlet var feedPopoverView: UIView!
    @IBOutlet weak var visualBlurEffectView: UIVisualEffectView!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBAction func tapBlurEffectView(_ sender: Any) {
        self.feedSelectionViewIsOpen.toggle()
        closePopoverView()
    }
    
    @IBOutlet weak var storiesContainerView: UIView!
    
    // feedButton pressed
    @IBAction func changeFeed(_ sender: Any) {
        
        self.feedSelectionViewIsOpen.toggle()
        
        if feedSelectionViewIsOpen {
            self.feedButton.image = nil
            self.feedButton.title = "Cancel"
            
            // Fade in the Transluscent View (Feed Selection)
            self.feedPopoverView.alpha = 0.0
            self.feedPopoverView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.feedPopoverView.alpha = 1.0
            }
            
            //self.tableView.isUserInteractionEnabled = false
            //self.feedPopoverView.isUserInteractionEnabled = true
        } else {
            closePopoverView()
        }
    }
    
    private let feedDataSource = FeedDataSource()
    var childVC: StoriesChildViewController?
    
    var feedSelectionViewIsOpen: Bool = false
    var feeds: [Feed] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedDataSource.delegate = self
        
        self.feeds = LoadDefaultFeeds().feeds
        configureFeedTableView(with: self.feeds)
        customizeFeedPopoverView()
        
        loadCurrentlySelectedFeedFromUserDefaults()
        childVC?.fetchStories()
    }
    
    /// Load The Previously Selected Feed ID from Userdefaults and update timestamps for feed URLs
    func loadCurrentlySelectedFeedFromUserDefaults() {
        
        var feedID = UserDefaults.standard.integer(forKey: "initialFeedID")
        
        //defaults.integer(forKey: "initialFeedID") will return 0 if the value is not found
        if feedID == 0 {
            // automatically select the default feed if the setting was never changed by the user: "Last 24h"
            feedID = 2
        }
        
        let selectedFeed = feeds.filter { $0.feedID == feedID }[0]
        let feedType = selectedFeed.feedType
        
        let feedURLstring = selectedFeed.feedURL
        guard var feedURLComponents = URLComponents(string: feedURLstring) else {
            return
        }
        
        if feedType == .algolia {
            if let feedFromCalendarComponentByAdding = selectedFeed.fromCalendarComponentByAdding {
                if let feedFromCalendarComponentValue = selectedFeed.fromCalendarComponentValue {
                    let currentTimestamp = Int(NSDate().timeIntervalSince1970)
                    let today = Date()
                    let priorDate = Calendar.current.date(byAdding: feedFromCalendarComponentByAdding, value: feedFromCalendarComponentValue, to: today)
                    let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
                    
                    let queryItemTimeRange = URLQueryItem(name: "numericFilters", value: "created_at_i>\(priorTimestamp),created_at_i<\(currentTimestamp)")
                    
                    feedURLComponents.addOrModify(queryItemTimeRange)
                }
            }
        }
        
        self.headerTitle.title = selectedFeed.feedName
        childVC?.currentSelectedSourceAPI = feedType
        childVC?.currentSelectedFeedURL = feedURLComponents
    }
    
    
    func closePopoverView() {
        self.feedButton.image = UIImage(named: "icn_feedSelect")
        self.feedButton.title = nil
        
        self.feedPopoverView.isHidden = true
    }
    
    /// Sets up a new TableView to select the Feed/Sort option.
    ///
    /// - Parameter feed: the [Feed] object - FeedList.plist parsed
    func configureFeedTableView(with feed: [Feed]) {
        feedDataSource.setData(feedList: feed)
        
        
        //Set height of the Feed Select tableview to be set automatic (based on the number of rows)
        let tableHeight = self.feedTableView.rowHeight * CGFloat(feed.count) + self.feedTableView.sectionHeaderHeight
        self.feedTableView.translatesAutoresizingMaskIntoConstraints = false
        self.feedTableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        
        self.feedTableView.layer.borderColor = UIColor.lightGray.cgColor
        self.feedTableView.layer.borderWidth = 1
        
        self.feedTableView.dataSource = feedDataSource
        self.feedTableView.delegate = feedDataSource
        self.feedTableView.register(FeedCell.self, forCellReuseIdentifier: "TableViewCell")
    }
    
    /// Sets up the Popover View which contains the Feed/Sort TableView.
    func customizeFeedPopoverView() {
        
        self.view.addSubview(feedPopoverView)
        feedPopoverView.translatesAutoresizingMaskIntoConstraints = false
        feedPopoverView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        feedPopoverView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        feedPopoverView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        feedPopoverView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        //feedPopoverView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        //feedPopoverView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        
        feedTableView.layer.cornerRadius = 8.0
        feedTableView.clipsToBounds = true
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedStoriesChildVC" {
            if let childDestination = segue.destination as? StoriesChildViewController {
                childDestination.parentVC = self
                self.childVC = childDestination
            }
        }
    }
    
}

// A new Feed was Selected from the Feed Selection View Controller
extension StoriesViewController: FeedDataSourceDelegate {
    func didTapCell(feedURL: URLComponents, title: String, type: HNFeedType) {
        
        //Cancel all existing requests which are in progress
        self.childVC?.defaultSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            for task in dataTasks {
                task.cancel()
            }
        }
        
        //Close the Feed Selection popup
        self.feedSelectionViewIsOpen.toggle()
        self.closePopoverView()
        
        //Fetch the new stories for the new Feed & Update the TableView
        self.headerTitle.title = title
        
        self.childVC?.currentSelectedSourceAPI = type
        self.childVC?.currentSelectedFeedURL = feedURL
        
        
        self.childVC?.fetchStories()
    }
    
}
