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

public enum BackhistoryOptions: String, CaseIterable {
    case allTime = "All time"
    case twoYears = "2 years"
    case oneYear = "1 year"
    case sixMonths = "6 months"
    case threeMonths = "3 months"
    case oneMonth = "1 month"
    case twoWeeks = "2 weeks"
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
    
    
    public func setBackhistory(at option: BackhistoryOptions) {
        UserDefaults.standard.set(option.rawValue, forKey: "backhistoryOption")
        
        var priorDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        
        switch option {
        case .allTime:
            priorDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
        case .twoYears:
            priorDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        case .oneYear:
            priorDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        case .sixMonths:
            priorDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        case .threeMonths:
            priorDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
        case .oneMonth:
            priorDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case .twoWeeks:
            priorDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        }
        let priorTimestamp = Int(priorDate!.timeIntervalSince1970)
        UserDefaults.standard.set(priorTimestamp, forKey: "backhistoryStartDate")
    }
    
    private init() {

        if let defaultApp = UserDefaults.standard.string(forKey: "defaultAppToOpenLinks") {
            defaultLinkOpenerDescription = defaultApp
        } else {
            // Fallback to Webview as the default option
            defaultLinkOpenerDescription = LinkOpener.webview.rawValue
        }
        
        hideSeen = UserDefaults.standard.bool(forKey: "hideSeen")
        hideRead = UserDefaults.standard.bool(forKey: "hideRead")
        
        if !launchedBefore  {
            // First launch, setting UserDefault.
            UserDefaults.standard.set(true, forKey: "appWasLaunchedBefore")
            
            UserDefaults.standard.set(true, forKey: "hideSeen")
            UserDefaults.standard.set(true, forKey: "hideRead")
            
            // Set Default Backhistory Date to 3 months prior
            self.setBackhistory(at: .threeMonths)
        }
    }
    
}
