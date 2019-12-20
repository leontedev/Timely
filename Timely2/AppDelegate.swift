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
    
    var firstTime: TimeInterval = 0.0
    var lastTime: TimeInterval = 0.0
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // initialize Singletons
        print(Defaults.shared)
        print(Feeds.shared)
        print(Bookmarks.shared)
        print(History.shared)
        
        
//        // Override point for customization after application launch.
//        let splitViewController = window!.rootViewController?.children[0] as! UISplitViewController
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//        splitViewController.delegate = self
//        // Forces devices where there is sufficient display estate to display both the master and detail VCs
//        splitViewController.preferredDisplayMode = .automatic
        
        
        
//        // SplitViewController bug for History & Bookmarks
//        let bookmarksSplitViewController = window!.rootViewController?.children[1] as! UISplitViewController
//        bookmarksSplitViewController.delegate = self
//        bookmarksSplitViewController.preferredDisplayMode = .allVisible
//
//        let historySplitViewController = window!.rootViewController?.children[2] as! UISplitViewController
//        historySplitViewController.delegate = self
//        historySplitViewController.preferredDisplayMode = .allVisible
//        //+END
        

//        // TODO: Check for dropped frames
//        let link = CADisplayLink(target: self, selector: #selector(update(link:)))
//        // add to the run loop
//        link.add(to: .main, forMode: .common)
        
        
        return true
    }
    
//    @objc func update(link: CADisplayLink) {
//        if lastTime == 0 {
//            firstTime = link.timestamp
//            lastTime = link.timestamp
//        }
//        
//        let currentTime = link.timestamp
//        _ = currentTime - firstTime
//        
//        // display in ms
//        let elapsedTime = floor((currentTime - lastTime) * 10_000)/10
//        
//        if elapsedTime > 16.7 {
//            print("")
//        }
//    }
    
    
//    // MARK: - Split view
//    
//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
//        
////        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
////
////        guard let topAsDetailController = secondaryAsNavController.topViewController as? CommentsViewController else { return false }
////
////        if topAsDetailController.algoliaStoryItem == nil {
////            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
////            return true
////        }
//      
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        History.shared.persistData()
        Bookmarks.shared.persistData()
    }

    // user pressed the Home button
    func applicationDidEnterBackground(_ application: UIApplication) {
        //Save the current timestamp to be used in the "Since Last Visit" feed
        let currentTimestamp = Int(NSDate().timeIntervalSince1970)
        UserDefaults.standard.set(currentTimestamp, forKey: "lastFeedLoadTimestamp")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      
      Feeds.shared.refreshSinceLastVisitFeedName()

    }

    func applicationWillTerminate(_ application: UIApplication) {
      
    }

    

}

