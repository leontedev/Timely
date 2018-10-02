//
//  ItemCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/26/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var upvotesCountLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
}
