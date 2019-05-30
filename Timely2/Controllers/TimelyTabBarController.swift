//
//  TimelyTabBarController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/23/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class TimelyTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("viewDidLoad >>>>>>>>>>> selectedIndex didSet \(selectedIndex)")
        
        self.delegate = self
        
        // Do any additional setup after loading the view.
    }
    

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.selectedViewController == viewController {
            
            if type(of: viewController) == StoriesSplitViewController.self {
                NotificationCenter.default.post(name: .tabBarStoriesTapped, object: nil)
            } else if type(of: viewController) == BookmarksSplitViewController.self {
                NotificationCenter.default.post(name: .tabBarBookmarksTapped, object: nil)
            } else if type(of: viewController) == HistorySplitViewController.self {
                NotificationCenter.default.post(name: .tabBarHistoryTapped, object: nil)
            }
        }
        
        return true
    }
    
    
}
