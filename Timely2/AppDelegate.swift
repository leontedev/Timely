//
//  AppDelegate.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // voiinitialize Singletons
        print(Feeds.shared)
        print(Bookmarks.shared)
        print(History.shared)
        
        
        // Override point for customization after application launch.
        let splitViewController = window!.rootViewController?.children[0] as! UISplitViewController
        
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        splitViewController.delegate = self
        
        // Forces devices where there is sufficient display estate to display both the master and detail VCs
        splitViewController.preferredDisplayMode = .allVisible
        

        
        
        
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        
        guard let topAsDetailController = secondaryAsNavController.topViewController as? CommentsViewController else { return false }
        
      if topAsDetailController.algoliaStoryItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        //Save the current timestamp to be used in the "Since Last Visit" feed
//        let currentTimestamp = Int(NSDate().timeIntervalSince1970)
//        UserDefaults.standard.set(currentTimestamp, forKey: "lastFeedLoadTimestamp")
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        History.shared.persistData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        History.shared.persistData()
    }

    

}

