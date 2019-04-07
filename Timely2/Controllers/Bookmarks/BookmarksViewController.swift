//
//  BookmarksViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/29/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController {
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookmarks" {
//            let controller = (segue.destination as! UINavigationController).topViewController as! StoriesChildViewController
            // initiate with the bookmarks list of story items

        }
        
    }

   

}
