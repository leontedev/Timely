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
    
    // DTCoreText
    func configure(htmlText: String) {
        let color = UIColor.black
        let fontSize: Float = 14
        
        var options = [
            DTCoreTextStub.kDTCoreTextOptionKeyFontSize(): NSNumber(value: Float(fontSize)),
            DTCoreTextStub.kDTCoreTextOptionKeyFontName(): "HelveticaNeue",
            DTCoreTextStub.kDTCoreTextOptionKeyFontFamily(): "Helvetica Neue",
            DTCoreTextStub.kDTCoreTextOptionKeyUseiOS6Attributes(): NSNumber(value: true),
            DTCoreTextStub.kDTCoreTextOptionKeyTextColor(): color] as [String? : Any]
        
        let attributedString = DTCoreTextStub.attributedString(withHtml: htmlText, options: options)
        
        if let atSt = attributedString {
            let mutableAttributedString = NSMutableAttributedString(attributedString: atSt)
            let range = NSMakeRange(0, atSt.length)
            mutableAttributedString.mutableString.replaceOccurrences(of: "\n", with: "", options: NSString.CompareOptions.caseInsensitive, range: range)

            commentLabel.attributedText = mutableAttributedString
            
        } else {
            print("NIL")
        }
        //
        
        //Strip out the extraneous \n added by DTCoreText
        //mutableAttributedString.mutableString.replaceOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: range)
        
        //apply any additional formatting
//        let stringRange = NSMakeRange(0, attrString.length)
//        var style = NSMutableParagraphStyle()
//        style.lineSpacing = 3.5
//        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: stringRange)
        
        
    }
    
}
