//
//  BookmarksViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/29/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController {
    
    private let bookmarksDataSource = BookmarksDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = bookmarksDataSource

    }



   

}
