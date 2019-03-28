//
//  AboutViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/27/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appIconImageView: UIImageView!
    
    let versionKey = "CFBundleShortVersionString"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let infoList = Bundle.main.infoDictionary!
        versionLabel.text = infoList[versionKey] as? String
        appIconImageView.image = UIImage.appIcon
    }
    
}
