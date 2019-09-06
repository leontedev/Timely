//
//  AboutViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/27/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
    
    var webView: WKWebView!

//    @IBOutlet weak var versionLabel: UILabel!
//    @IBOutlet weak var appIconImageView: UIImageView!
//
//    let versionKey = "CFBundleShortVersionString"
    
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
