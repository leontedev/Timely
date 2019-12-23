//
//  CopyrightViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 23/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit
import WebKit

class CopyrightViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        //webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://github.com/leontedev/Timely")!
        let request = URLRequest(url: url)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
    }
    
}
