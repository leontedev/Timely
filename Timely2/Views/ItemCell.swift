//
//  ItemCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/26/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    static let reuseIdentifier = "ItemCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var upvotesCountLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    override func layoutSubviews() {
        // Custom layout cells don't apply indentationLevel automatically. We need to update layoutMargins manually
        super.layoutSubviews()
        contentView.layoutMargins.left = layoutMargins.left + CGFloat(indentationLevel) * indentationWidth
        
        // Automatically resize when font changes are initiated
        titleLabel.adjustsFontForContentSizeCategory = true
        updateFontSizeUI()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(fontSizeDidModify),
                                       name: .storiesLabelAppearanceChanged,
                                       object: nil
        )
        
        
    }
    
    func updateFontSizeUI() {
        let isSetToUseCustomFontForStories: Bool = UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForStories")
        let customFontSizeStories: Float = UserDefaults.standard.float(forKey: "customFontSizeStories")
        
        if isSetToUseCustomFontForStories {
            titleLabel.font = titleLabel.font.withSize(CGFloat(customFontSizeStories))
        } else {
            titleLabel.font = .preferredFont(forTextStyle: .body)
        }
    }
    
    @objc private func fontSizeDidModify(_ notification: Notification) {
        updateFontSizeUI()
    }

}
