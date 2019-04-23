//
//  BookmarksViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/29/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit
import os


class BookmarksViewController: UIViewController {
    var childVC: StoriesChildViewController?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("BookmarksViewController did load.", log: OSLog.viewCycle, type: .debug)
        
        guard let childVC = childVC else { return }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshBookmarkHeaderCount),
                                               name: .bookmarkAdded,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshBookmarkHeaderCount),
                                               name: .bookmarkRemoved,
                                               object: nil
        )
        
        childVC.currentSelectedSourceAPI = .official
        
        if Bookmarks.shared.stories.isEmpty {
            childVC.state = .empty
            self.navigationItem.title = "Bookmarks"
        } else {
            let bookmarksCount = String(Bookmarks.shared.stories.count)
            self.navigationItem.title = "Bookmarks (\(bookmarksCount))"
            
            childVC.state = .loading
            childVC.storiesOfficialAPI = Bookmarks.shared.stories
            childVC.state = .populated
            childVC.fetchOfficialApiStoryItems()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshBookmarkHeaderCount() {
        let bookmarksCount = Bookmarks.shared.stories.count
        if bookmarksCount > 0 {
            self.navigationItem.title = "Bookmarks (\(bookmarksCount))"
        } else {
            self.navigationItem.title = "Bookmarks"
        }
        
    }

    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedBookmarksChildVC" {
            if let childDestination = segue.destination as? StoriesChildViewController {
                self.childVC = childDestination
                self.addChild(childDestination)
                self.childVC?.didMove(toParent: self)
            }
        }
    }
}
