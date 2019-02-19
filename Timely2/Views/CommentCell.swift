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
    
    //@IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var commentStackView: UIStackView!
    
    override func layoutSubviews() {
        // Custom layout cells don't apply indentationLevel automatically. We need to update layoutMargins manually
        super.layoutSubviews()
        contentView.layoutMargins.left = layoutMargins.left + CGFloat(indentationLevel) * indentationWidth
    }
    

}
