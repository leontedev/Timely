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
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.popToRootViewController(animated: true)
        
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
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "StoriesChildViewID") as? StoriesChildViewController else { return }
        vc.parentType = .bookmarks
        self.view.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
        self.childVC = vc
        vc.currentSelectedSourceAPI = .official
        
        if Bookmarks.shared.items.isEmpty {
            vc.state = .empty
            self.navigationItem.title = "Bookmarks"
        } else {
            let bookmarksCount = String(Bookmarks.shared.items.count)
            self.navigationItem.title = "Bookmarks (\(bookmarksCount))"
            
            vc.refreshBookmarks()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshBookmarkHeaderCount() {
        let bookmarksCount = Bookmarks.shared.items.count
        if bookmarksCount > 0 {
            self.navigationItem.title = "Bookmarks (\(bookmarksCount))"
        } else {
            self.navigationItem.title = "Bookmarks"
        }
        
    }

}
