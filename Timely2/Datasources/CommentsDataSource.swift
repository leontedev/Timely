//
//  CommentsDataSource.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/1/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation

class CommentsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var story: Story?
    var comments: [CommentSource] = []
    
    // Section indexes
    let STORY_CELL_SECTION = 0
    let STORY_BUTTONS_CELL_SECTION = 1
    let COMMENT_CELL_SECTION = 2
    
    let COLLAPSED_ROW_HEIGHT = 38
    
    func setData(story: Story, comments: [CommentSource]) {
        self.story = story
        self.comments = comments
    }
    
    //MARK: - DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        debugLog()
        if section == COMMENT_CELL_SECTION {
            return self.comments.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommentCell!
        
        if indexPath.section == COMMENT_CELL_SECTION {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierComment, for: indexPath) as? CommentCell
            
            let item = self.comments[indexPath.row].comment
            let depth = self.comments[indexPath.row].depth
            
            // Indent cell based on comment depth
            let indent = CGFloat(depth) * 15
            cell.commentStackView.layoutMargins = UIEdgeInsets(top: 0, left: indent, bottom: 0, right: 0)
            cell.commentStackView.isLayoutMarginsRelativeArrangement = true
            //cell.indentationWidth = 15
            //cell.indentationLevel = Int(depth)
            
            // Indent the separator line between the cells
            let separatorIndent = CGFloat(15 + indent)
            cell.separatorInset = UIEdgeInsetsMake(0, separatorIndent, 0, 0)
            
            
            if let attributedString = self.comments[indexPath.row].attributedString {
                cell.commentTextView?.attributedText = attributedString
            } else {
                debugLog()
                if let commentText = item.text {
                    // Use Apple's HTML to Attributed String parser and trimit whitespaces and extra new lines
                    cell.commentTextView.attributedText = commentText.htmlToAttributedString?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            cell.byUserLabel?.text = item.author
            cell.elapsedTimeLabel?.text = self.comments[indexPath.row].timeAgo
            
        } else if indexPath.section == STORY_CELL_SECTION {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierStory, for: indexPath) as? CommentCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            if let title = self.story?.title {
                cell.titleLabel.text = title
            }
            
            if let url = self.story?.url {
                cell.urlLabel.text = url.absoluteString
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(StoriesDetailViewController.labelTapped))
                cell.urlLabel.isUserInteractionEnabled = true
                cell.urlLabel.addGestureRecognizer(tap)
            }
            
            if let author = self.story?.author {
                cell.storyUsernameLabel.text = author
            }
            
            if let createdAt = self.story?.createdAt {
                let componentsFormatter = DateComponentsFormatter()
                componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                componentsFormatter.maximumUnitCount = 1
                componentsFormatter.unitsStyle = .abbreviated
                
                let timeAgo = componentsFormatter.string(from: createdAt, to: Date())
                cell.storyElapsedLabel.text = timeAgo
            }
            
            if let numComments = self.story?.numComments {
                cell.storyNumComments.text = String(numComments)
                
            }
            
            if let points = self.story?.points {
                cell.storyPoints.text = String(points)
            }
            
            if let text = self.story?.text {
                cell.storyText.attributedText = text.htmlToAttributedString
            }
            
        } else if indexPath.section == STORY_BUTTONS_CELL_SECTION {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierStoryButtons, for: indexPath) as? CommentCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.storyURL = self.story?.url
            //cell.parentVC = self
            cell.shareItems = [story?.title as Any, story?.url as Any]
            
        }
        
        return cell
    }
    
    // MARK: - Delegates
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == COMMENT_CELL_SECTION {
            if !self.comments[indexPath.row].collapsed {
                
                let selectedItemDepth = self.comments[indexPath.row].depth
                
                //self.collapsedCellsIndexPaths.append(indexPath)
                self.comments[indexPath.row].height = self.COLLAPSED_ROW_HEIGHT
                self.comments[indexPath.row].collapsed = true
                
                // Find all the child comments
                var index = indexPath.row + 1
                var childCommentsForRemoval: [IndexPath] = []
                while index < self.comments.count && self.comments[index].depth > selectedItemDepth {
                    // Construct the array of removed Comments to be able to retrieve them on Expanding the collapsed comment tree
                    self.comments[indexPath.row].removedComments.append(self.comments[index])
                    // FIXME: [IndexPath] for rows to be deleted
                    childCommentsForRemoval.append(IndexPath(row: index, section: COMMENT_CELL_SECTION))
                    
                    index = index + 1
                }
                
                if childCommentsForRemoval.count > 0 {
                    
                    for childComment in childCommentsForRemoval.sorted(by: >) {
                        self.comments.remove(at: childComment.row)
                    }
                    
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: childCommentsForRemoval, with: UITableViewRowAnimation.fade)
                    }, completion: nil)
                }
                
                //these tell the tableview something changed, and it checks cell heights and animates changes
                tableView.beginUpdates()
                tableView.endUpdates()
            } else {
                self.comments[indexPath.row].height = nil
                self.comments[indexPath.row].collapsed = false
                
                if self.comments[indexPath.row].removedComments.count > 0 {
                    //re-insert the previously removed child comments (with higher depths)
                    self.comments.insert(contentsOf: self.comments[indexPath.row].removedComments, at: indexPath.row + 1)
                    
                    var indexPaths: [IndexPath] = []
                    for (index, _) in self.comments[indexPath.row].removedComments.enumerated() {
                        indexPaths.append(IndexPath(row: index + indexPath.row + 1, section: COMMENT_CELL_SECTION))
                    }
                    tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
                    self.comments[indexPath.row].removedComments.removeAll()
                    
                }
                tableView.beginUpdates()
                tableView.endUpdates()
                
            }
        }
        
        // To deselect the collapsed/expanded cell upon reload (otherwise it remains highligted)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == COMMENT_CELL_SECTION && self.comments.count > 0 {
            if let height = self.comments[indexPath.row].height {
                return CGFloat(integerLiteral: height)
            }
        }
        return UITableViewAutomaticDimension
    }
}
