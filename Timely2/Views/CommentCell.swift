//
//  CommentCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/28/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit
import SafariServices

class CommentCell: UITableViewCell {
    
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    
    var shareItems: [Any] = []
    var storyURL: URL?
    weak var parentVC: UIViewController?
    
    // First static cell which contains the Story Information
    static let reuseIdentifierStory = "StoryCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var storyElapsedLabel: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    @IBOutlet weak var storyNumComments: UILabel!
    @IBOutlet weak var storyPoints: UILabel!
    @IBOutlet weak var storyText: UILabel!
    
    
    // Second static cell which contains the buttons for the Story actions
    static let reuseIdentifierStoryButtons = "StoryButtonsCell"
    
    @IBOutlet weak var shareButton: UIButton!
    
    func showSafariVC(for url: URL?) {
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            if let detailViewController = parentVC {
                detailViewController.present(safariVC, animated: true)
            }
        }
    }
    
    func displayShareSheet() {
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        if let detailViewController = parentVC {
            detailViewController.present(activityViewController, animated: true)
        }
    }
    
    @IBAction func safariButtonPressed() {
        if let url = storyURL {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func webviewButtonPressed() {
        showSafariVC(for: self.storyURL)
    }
    
    @IBAction func shareButtonPressed() {
        displayShareSheet()
    }
    
    // Third dynamic cell - which contain the comments
    static let reuseIdentifierComment = "CommentCell"
    
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    
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
