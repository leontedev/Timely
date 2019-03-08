//
//  SettingsSplitViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/7/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class SettingsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    // present the Master View Controller when first loaded, instead of the Detail View Controller (as that's the default behavior)
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
