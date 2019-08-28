//
//  Defaults.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/9/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//



enum LinkOpener: String, CaseIterable {
    case safari = "Safari"
    case webview = "Timely"
}

public class Defaults {
    static let shared = Defaults()
    
    // initially, if userdefaults is not set, it will return false
    let launchedBefore = UserDefaults.standard.bool(forKey: "appWasLaunchedBefore")
    
    var defaultLinkOpenerDescription: String {
        didSet {
            UserDefaults.standard.set(defaultLinkOpenerDescription, forKey: "defaultAppToOpenLinks")
        }
    }
    
    var hideSeen: Bool {
        didSet {
            UserDefaults.standard.set(hideSeen, forKey: "hideSeen")
        }
    }
    
    var hideRead: Bool {
        didSet {
            UserDefaults.standard.set(hideRead, forKey: "hideRead")
        }
    }
    
    
    private init() {
        
        if !launchedBefore  {
            // First launch, setting UserDefault.
            UserDefaults.standard.set(true, forKey: "appWasLaunchedBefore")
            
            // Set Default Backhistory Date to 3 months prior
            let priorDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
            let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
            UserDefaults.standard.set(priorTimestamp, forKey: "backhistoryStartDate")
            
            UserDefaults.standard.set(true, forKey: "hideSeen")
            UserDefaults.standard.set(true, forKey: "hideRead")
        }

        if let defaultApp = UserDefaults.standard.string(forKey: "defaultAppToOpenLinks") {
            defaultLinkOpenerDescription = defaultApp
        } else {
            // Fallback to Webview as the default option
            defaultLinkOpenerDescription = LinkOpener.webview.rawValue
        }
        
        hideSeen = UserDefaults.standard.bool(forKey: "hideSeen")
        hideRead = UserDefaults.standard.bool(forKey: "hideRead")

    }
    
}
