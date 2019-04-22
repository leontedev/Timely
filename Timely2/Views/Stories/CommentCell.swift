//
//  CommentCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/28/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    // Required to dynamically modify the font size of the comments from Settings / Appearance
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    // Third dynamic cell - which contains the comments
    static let reuseIdentifierComment = "CommentCell"
    
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    
    @IBOutlet weak var elapsedImage: UIImageView!
    @IBOutlet weak var authorImage: UIImageView!
    
    
    override func layoutSubviews() {
        // Custom layout cells don't apply indentationLevel automatically. We need to update layoutMargins manually
        super.layoutSubviews()
        contentView.layoutMargins.left = layoutMargins.left + CGFloat(indentationLevel) * indentationWidth
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if commentTextView != nil {
            commentTextView.adjustsFontForContentSizeCategory = true
            updateFontSizeUI()
            
            notificationCenter.addObserver(self,
                                           selector: #selector(fontSizeDidModify),
                                           name: .commentsLabelAppearanceChanged,
                                           object: nil
            )
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc private func fontSizeDidModify(_ notification: Notification) {
        updateFontSizeUI()
    }
    
    func updateFontSizeUI() {
        let isSetToUseCustomFontForComments: Bool = UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForComments")
        let customFontSizeComments: Float = UserDefaults.standard.float(forKey: "customFontSizeComments")
        
        if isSetToUseCustomFontForComments {
            let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeComments))
            commentTextView.font = UIFontMetrics.default.scaledFont(for: font)
        } else {
            commentTextView.font = .preferredFont(forTextStyle: .body)
        }
        
    }

}
