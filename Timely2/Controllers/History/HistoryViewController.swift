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
        NotificationCenter.default.post(name: .historyCleared, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("HistoryViewController did load.", log: OSLog.viewCycle, type: .debug)
        
        print("******************* History was loaded.")
        
        guard let childVC = childVC else { return }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshHistoryHeaderCount),
                                               name: .historyAdded,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshHistoryHeaderCount),
                                               name: .historyItemRemoved,
                                               object: nil
        )
    
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(refreshHistoryHeaderCount),
                                                name: .historyCleared,
                                                object: nil
        )
        
        childVC.currentSelectedSourceAPI = .official
        
        if History.shared.items.isEmpty {
            childVC.state = .empty
            self.navigationItem.title = "History"
        } else {
            let historyCount = String(History.shared.items.count)
            self.navigationItem.title = "History (\(historyCount))"
            
            childVC.refreshHistory()
        }
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshHistoryHeaderCount() {
        let historyCount = History.shared.items.count
        
        if historyCount > 0 {
            self.navigationItem.title = "History (\(historyCount))"
        } else {
            self.navigationItem.title = "History"
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
