//
//  UIImage.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/27/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
// get the AppIcon
extension UIImage {
    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
}
