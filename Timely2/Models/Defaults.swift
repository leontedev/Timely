//
//  Defaults.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/9/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

enum LinkOpener: String, CaseIterable {
    case safari = "Safari"
    case webview = "Timely"
}

public class Defaults {
    static let shared = Defaults()
    var defaultLinkOpenerDescription: String = "" {
        didSet {
            UserDefaults.standard.set(defaultLinkOpenerDescription, forKey: "defaultAppToOpenLinks")
        }
    }
    
    private init() {

        if let defaultApp = UserDefaults.standard.string(forKey: "defaultAppToOpenLinks") {
            defaultLinkOpenerDescription = defaultApp
        } else {
            // Fallback to Webview as the default option
            defaultLinkOpenerDescription = LinkOpener.webview.rawValue
        }
        
    }
    
}
