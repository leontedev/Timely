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
    @IBOutlet weak var bookmarkedTimeLabel: UILabel!
    @IBOutlet weak var bookmarkedTimeImage: UIImageView!
    @IBOutlet weak var commentsCountImage: UIImageView!
    @IBOutlet weak var upvotesCountImage: UIImageView!
    @IBOutlet weak var elapsedTimeImage: UIImageView!
    @IBOutlet weak var urlAndCircleStackView: UIStackView!
    
    var newStoryCircleView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
    
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
        
        
        newStoryCircleView.backgroundColor = UIColor(named: "ButtonColor")
        newStoryCircleView.layer.cornerRadius = 8
        newStoryCircleView.isHidden = true

        // Define size constraints for the new Circle View (otherwise it will be shrunk to 0:0
        newStoryCircleView.translatesAutoresizingMaskIntoConstraints = false
        newStoryCircleView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        newStoryCircleView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        // Add the black/orange bullet on the right side of stories to mark the ones which are NEW (Unread & Unseen)
        urlAndCircleStackView.addArrangedSubview(newStoryCircleView)
        
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
