//
//  CommentStoryCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/2/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class CommentStoryCell: UITableViewCell {
    // First static cell which contains the Story Information
    static let reuseIdentifier = "StoryCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var storyElapsedLabel: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    @IBOutlet weak var storyNumComments: UILabel!
    @IBOutlet weak var storyPoints: UILabel!
    @IBOutlet weak var storyText: UILabel!
    
}
