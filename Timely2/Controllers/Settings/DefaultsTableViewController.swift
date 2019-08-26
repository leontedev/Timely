//
//  DefaultsTableViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/8/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit


class DefaultsTableViewController: UITableViewController {
    
    @IBOutlet weak var defaultFeedCell: UITableViewCell!
    @IBOutlet weak var openLinksInCell: UITableViewCell!
    @IBOutlet weak var backhistoryCell: UITableViewCell!
    @IBOutlet weak var hideSeenCell: UITableViewCell!
    @IBOutlet weak var hideReadCell: UITableViewCell!
    
    @IBOutlet weak var defaultFeedLabel: UILabel!
    @IBOutlet weak var openLinksInLabel: UILabel!
    @IBOutlet weak var backhistoryLabel: UILabel!
    @IBOutlet weak var hideSeenSwitch: UISwitch!
    @IBOutlet weak var hideReadSwitch: UISwitch!
    
    let feeds = Feeds.shared.feeds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateTableViewDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
                Feeds.shared.isSetPreviouslySelectedFeed = true
                self.refreshTableView()
            }
            alertController.addAction(previouslyUsedAction)
            
            // Feeds options
            for feed in feeds {
                let defaultFeedAction = UIAlertAction(title: feed.feedName, style: .default) { action in
                    Feeds.shared.selectedFeed = feed
                    self.refreshTableView()
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
                    Defaults.shared.defaultLinkOpenerDescription = appOption.rawValue
                    self.refreshTableView()
                }
                alertController.addAction(appAction)
            }
            
            self.present(alertController, animated: true) { }
        } else if cell === backhistoryCell {
//            let alertController = UIAlertController(title: nil, message: "Select backhistory period", preferredStyle: .actionSheet)
//            
//            // Cancel option
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//                self.tableView.deselectRow(at: indexPath, animated: true)
//            }
//            alertController.addAction(cancelAction)
//            
//            
//            var appAction = UIAlertAction(title: "1 month", style: .default) { (action) in
//                Defaults.shared.defaultLinkOpenerDescription = appOption.rawValue
//                self.refreshTableView()
//            }
//            alertController.addAction(appAction)
//            
//            
//            self.present(alertController, animated: true) { }
        }
        
    }
    
    
    //MARK: - Helper Functions
    func updateTableViewDataSource() {
        self.defaultFeedLabel.text = Feeds.shared.defaultFeedDescription
        self.openLinksInLabel.text = Defaults.shared.defaultLinkOpenerDescription
    }
    
    func refreshTableView() {
        self.updateTableViewDataSource()
        self.tableView.reloadData()
    }
    
}
