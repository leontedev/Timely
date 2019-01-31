//
//  CommentCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/28/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit
//import DTCoreText
//import DTFoundation

class CommentCell: UITableViewCell {
    static let reuseIdentifierComment = "CommentCell"
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var byUserLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    
    override func layoutSubviews() {
        // Custom layout cells don't apply indentationLevel automatically. We need to update layoutMargins manually
        super.layoutSubviews()
        contentView.layoutMargins.left = layoutMargins.left + CGFloat(indentationLevel) * indentationWidth
    }
    
    static let reuseIdentifierStory = "StoryCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var storyElapsedLabel: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    @IBOutlet weak var storyNumComments: UILabel!
    @IBOutlet weak var storyPoints: UILabel!
    @IBOutlet weak var storyText: UILabel!
    
    static let reuseIdentifierStoryButtons = "StoryButtonsCell"
    

}
