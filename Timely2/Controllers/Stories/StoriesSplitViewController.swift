//
//  StoriesSplitViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/30/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class StoriesSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        // Do any additional setup after loading the view.
    }
    

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        
        // Return true to prevent UIKit from applying its default behavior
        return true
    }

}
