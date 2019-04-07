//
//  ItemCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/26/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class StoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var upvotesCountLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    static let reuseIdentifier = "ItemCell"
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        
        notificationCenter.addObserver(self,
                                       selector: #selector(fontSizeDidModify),
                                       name: .storiesLabelAppearanceChangingFinished,
                                       object: nil
        )
        
        updateFontSizeUI()
    }
    
    @objc private func fontSizeDidModify(_ notification: Notification) {
        updateFontSizeUI()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func layoutSubviews() {
        // Custom layout cells don't apply indentationLevel automatically. We need to update layoutMargins manually
        super.layoutSubviews()
        contentView.layoutMargins.left = layoutMargins.left + CGFloat(indentationLevel) * indentationWidth
    }
    
    func updateFontSizeUI() {
        let isSetToUseCustomFontForStories: Bool = UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForStories")
        let customFontSizeStories: Float = UserDefaults.standard.float(forKey: "customFontSizeStories")
        
        if isSetToUseCustomFontForStories {
            let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeStories))
            titleLabel.font = UIFontMetrics.default.scaledFont(for: font)
            //titleLabel.font = titleLabel.font.withSize(CGFloat(customFontSizeStories))
        } else {
            titleLabel.font = .preferredFont(forTextStyle: .body)
        }
        

    }
    
    

}
