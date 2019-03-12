//
//  AppearanceTableViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/8/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class AppearanceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }

}
