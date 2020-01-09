//
//  BookmarksSplitViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/7/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class BookmarksSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // present the Master View Controller when first loaded, instead of the Detail View Controller (as that's the default behavior)
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
