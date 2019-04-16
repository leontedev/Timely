//
//  HistoryViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/12/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

import UIKit
import os


class HistoryViewController: UIViewController {
    var childVC: StoriesChildViewController?
    
    @IBAction func clearHistoryPressed(_ sender: Any) {
        History.shared.removeHistory()
        childVC?.refreshHistory()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("HistoryViewController did load.", log: OSLog.viewCycle, type: .debug)
        
        guard let childVC = childVC else { return }
        
        childVC.isStoriesChildView = false
        childVC.currentSelectedSourceAPI = .official
        childVC.state = .loading
        if History.shared.items.isEmpty {
            childVC.state = .empty
        } else {
            childVC.storiesOfficialAPI = History.shared.stories
            childVC.state = .populated
            childVC.fetchOfficialApiStoryItems()
        }
        
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedHistoryChildVC" {
            if let childDestination = segue.destination as? StoriesChildViewController {
                self.childVC = childDestination
                self.addChild(childDestination)
                self.childVC?.didMove(toParent: self)
            }
        }
    }
    
}
