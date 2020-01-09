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
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.popToRootViewController(animated: true)
 
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
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "StoriesChildViewID") as? StoriesChildViewController else { return }
        vc.parentType = .history
        self.containerView.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
        self.childVC = vc
        vc.currentSelectedSourceAPI = .official
        
        if History.shared.readItems.isEmpty {
            vc.state = .empty
            self.navigationItem.title = "History"
        } else {
            let historyCount = String(History.shared.readItems.count)
            self.navigationItem.title = "History (\(historyCount))"
            vc.refreshHistory()
        }
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refreshHistoryHeaderCount() {
        let historyCount = History.shared.sortedIds.count
        
        if historyCount > 0 {
            self.navigationItem.title = "History (\(historyCount))"
        } else {
            self.navigationItem.title = "History"
        }
    }

    
}
