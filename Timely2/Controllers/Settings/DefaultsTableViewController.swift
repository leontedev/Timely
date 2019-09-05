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
        
        //self.updateTableViewDataSource()
        self.defaultFeedLabel.text = Feeds.shared.defaultFeedDescription
        self.openLinksInLabel.text = Defaults.shared.defaultLinkOpenerDescription
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        
        let timestamp = Date(timeIntervalSince1970: TimeInterval(Defaults.shared.backhistoryStartDate))
        let date = dateFormatter.string(from: timestamp)
        
        self.backhistoryLabel.text = "from \(date)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        hideSeenCell.selectionStyle = .none
        hideReadCell.selectionStyle = .none
        hideSeenSwitch.isOn = Defaults.shared.hideSeen
        hideReadSwitch.isOn = Defaults.shared.hideRead
        
    }
    
    @IBAction func toggleHideSeen(_ sender: UISwitch) {
        Defaults.shared.hideSeen = sender.isOn
    }
    
    @IBAction func toggleHideRead(_ sender: UISwitch) {
        Defaults.shared.hideRead = sender.isOn
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
                self.defaultFeedLabel.text = Feeds.shared.defaultFeedDescription
                self.tableView.reloadData()
            }
            alertController.addAction(previouslyUsedAction)
            
            // Feeds options
            for feed in feeds {
                let defaultFeedAction = UIAlertAction(title: feed.feedName, style: .default) { action in
                    Feeds.shared.selectedFeed = feed
                    self.defaultFeedLabel.text = Feeds.shared.defaultFeedDescription
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
                    Defaults.shared.defaultLinkOpenerDescription = appOption.rawValue
                    self.openLinksInLabel.text = appOption.rawValue
                    self.tableView.reloadData()
                    
                }
                alertController.addAction(appAction)
            }
            
            self.present(alertController, animated: true) { }
        } else if cell === backhistoryCell {
            let alertController = UIAlertController(title: nil, message: "Select backhistory period", preferredStyle: .actionSheet)

            // Cancel option
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            alertController.addAction(cancelAction)

            for option in BackhistoryOptions.allCases {
                var appAction = UIAlertAction(title: option.rawValue, style: .default) { (action) in
                    Defaults.shared.setBackhistory(at: option)
                    
                    self.backhistoryLabel.text = option.rawValue
                    self.tableView.reloadData()
                }
                alertController.addAction(appAction)
            }
            
            self.present(alertController, animated: true) { }
        }
        
    }
    
    
    //MARK: - Helper Functions
//    func updateTableViewDataSource() {
//        self.defaultFeedLabel.text = Feeds.shared.defaultFeedDescription
//
//    }
//
//    func refreshTableView() {
//        self.updateTableViewDataSource()
//        self.tableView.reloadData()
//    }
    
}
