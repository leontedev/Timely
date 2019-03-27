//
//  DefaultsTableViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/8/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

enum LinkOpener: String, CaseIterable {
    case safari = "Safari"
    case webview = "Timely"
}

class DefaultsTableViewController: UITableViewController {

    @IBOutlet weak var defaultFeedCell: UITableViewCell!
    @IBOutlet weak var openLinksInCell: UITableViewCell!
    
    @IBOutlet weak var defaultFeedLabel: UILabel!
    @IBOutlet weak var openLinksInLabel: UILabel!
    
    let feeds = LoadDefaultFeeds().feeds
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.updateTableViewDataSource()
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell === defaultFeedCell {
            
            let alertController = UIAlertController(title: nil, message: "Select the default Feed to load when opening the app", preferredStyle: .actionSheet)
            
            // Cancel option
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            alertController.addAction(cancelAction)
            
            // Previously Selected option
            let previouslyUsedAction = UIAlertAction(title: "Previously Selected", style: .default) { action in
                UserDefaults.standard.set(true, forKey: "isPreviouslySelectedFeed")
                
                self.updateTableViewDataSource()
                self.tableView.reloadData()
            }
            alertController.addAction(previouslyUsedAction)
            
            // plist Feeds options
            for feed in feeds {
                let defaultFeedAction = UIAlertAction(title: feed.feedName, style: .default) { action in
                    UserDefaults.standard.set(feed.feedID, forKey: "initialFeedID")
                    UserDefaults.standard.set(false, forKey: "isPreviouslySelectedFeed")
                    
                    self.updateTableViewDataSource()
                    self.tableView.reloadData()
                }
                alertController.addAction(defaultFeedAction)
            }
            
            self.present(alertController, animated: true) { }
            
        } else if cell === openLinksInCell {
            let alertController = UIAlertController(title: nil, message: "Select the default way to open links", preferredStyle: .actionSheet)
            
            // Cancel option
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            alertController.addAction(cancelAction)
            
            for appOption in LinkOpener.allCases {
                let appAction = UIAlertAction(title: appOption.rawValue, style: .default) { (action) in
                    UserDefaults.standard.set(appOption.rawValue, forKey: "defaultAppToOpenLinks")
                    
                    self.updateTableViewDataSource()
                    self.tableView.reloadData()
                }
                alertController.addAction(appAction)
            }
            
            self.present(alertController, animated: true) { }
        }
    }
    
    //MARK: - Helper Functions
    func updateTableViewDataSource() {
        let isPreviouslySelectedFeed = UserDefaults.standard.bool(forKey: "isPreviouslySelectedFeed")
        
        if isPreviouslySelectedFeed {
            defaultFeedLabel.text = "Previously Selected"
        } else {
            let feedID = UserDefaults.standard.integer(forKey: "initialFeedID")
            
            if feedID == 0 {
                // id = 2 is set as the default in StoriesMasterViewController.swift, search for if feedID == 0 {
                let selectedFeed = feeds.filter { $0.feedID == 2 }[0]
                self.defaultFeedLabel.text = selectedFeed.feedName
            } else {
                let selectedFeed = feeds.filter { $0.feedID == feedID }[0]
                self.defaultFeedLabel.text = selectedFeed.feedName
            }
        }
        
        let defaultAppToOpenLinks = UserDefaults.standard.string(forKey: "defaultAppToOpenLinks")
        
        if let defaultApp = defaultAppToOpenLinks {
            openLinksInLabel.text = defaultApp
        } else {
            openLinksInLabel.text = LinkOpener.webview.rawValue
        }
        
    }



}
