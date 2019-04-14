//
//  CommentsDataSource.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/1/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import Foundation
import SafariServices


class CommentsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var story: Story?
    var comments: [CommentSource] = []
    weak var parentVC: UIViewController?
    
    // Section indexes
    let STORY_CELL_SECTION = 0
    let STORY_BUTTONS_CELL_SECTION = 1
    let COMMENT_CELL_SECTION = 2
    
    let COLLAPSED_ROW_HEIGHT = 38
    
    func setData(parent: UIViewController, story: Story, comments: [CommentSource]) {
        self.story = story
        self.comments = comments
        self.parentVC = parent
    }
    
    //MARK: - DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == COMMENT_CELL_SECTION {
            return self.comments.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == COMMENT_CELL_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierComment, for: indexPath) as! CommentCell
            
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
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: separatorIndent, bottom: 0, right: 0)
            
            
            if let attributedString = self.comments[indexPath.row].attributedString {
                cell.commentTextView?.attributedText = attributedString
            } else {
                if let commentText = item.text {
                    // Use Apple's HTML to Attributed String parser and trimit whitespaces and extra new lines
                    cell.commentTextView.attributedText = commentText.htmlToAttributedString?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            cell.byUserLabel?.text = item.author
            cell.elapsedTimeLabel?.text = self.comments[indexPath.row].timeAgo
            
            
            // Grey out the visible area (the Elapsed & Author icons) for collapsed comments
            
            if self.comments[indexPath.row].collapsed {
                cell.elapsedImage.alpha = CGFloat(0.4)
                cell.authorImage.alpha = CGFloat(0.4)
            } else {
                cell.elapsedImage.alpha = CGFloat(1.0)
                cell.authorImage.alpha = CGFloat(1.0)
            }
            
            return cell
        } else if indexPath.section == STORY_CELL_SECTION {
    
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentStoryCell.reuseIdentifier, for: indexPath) as! CommentStoryCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            if let title = self.story?.title {
                cell.titleLabel.text = title
            }
            
            if let url = self.story?.url {
                cell.urlLabel.text = url.absoluteString
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(CommentsDataSource.labelTapped))
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
            
            return cell
        } else if indexPath.section == STORY_BUTTONS_CELL_SECTION {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentNavBarCell.reuseIdentifier, for: indexPath) as! CommentNavBarCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.storyURL = self.story?.url
            cell.storyID = self.story?.id
            cell.parentVC = self.parentVC
            cell.shareItems = [story?.title as Any, story?.url as Any]
            
            return cell
        }
        
        // FIXME: Not sure how I can avoid this mess below :(
        let cell2: UITableViewCell!
        cell2 = tableView.dequeueReusableCell(withIdentifier: CommentNavBarCell.reuseIdentifier, for: indexPath)
        return cell2
    }
    
    // MARK: - Delegates
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        
        if indexPath.section == COMMENT_CELL_SECTION {
            
            // check if the comment (and it's leaves) are already marked as collapsed
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
                        tableView.deleteRows(at: childCommentsForRemoval, with: UITableView.RowAnimation.fade)
                    }, completion: nil)
                }

                feedbackGenerator.notificationOccurred(.success)
                //these tell the tableview something changed, and it checks cell heights and animates changes
                tableView.beginUpdates()
                tableView.endUpdates()
                
                // required in order to grey out the elapsed & author icons
                tableView.reloadRows(at: [indexPath], with: .none)
                
            } else {
                
                self.comments[indexPath.row].height = nil
                self.comments[indexPath.row].collapsed = false
                
                tableView.reloadRows(at: [indexPath], with: .none)
                
                if self.comments[indexPath.row].removedComments.count > 0 {
                    //re-insert the previously removed child comments (with higher depths)
                    self.comments.insert(contentsOf: self.comments[indexPath.row].removedComments, at: indexPath.row + 1)
                    
                    var indexPaths: [IndexPath] = []
                    for (index, _) in self.comments[indexPath.row].removedComments.enumerated() {
                        indexPaths.append(IndexPath(row: index + indexPath.row + 1, section: COMMENT_CELL_SECTION))
                    }
                    tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.bottom)
                    self.comments[indexPath.row].removedComments.removeAll()
                    
                }
                
                feedbackGenerator.notificationOccurred(.success)
                
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
        return UITableView.automaticDimension
    }
    
    @objc func labelTapped(sender:UITapGestureRecognizer) {
        if let url = story?.url {
            
            let defaultAppToOpenLinks = UserDefaults.standard.string(forKey: "defaultAppToOpenLinks")
            if let defaultApp = defaultAppToOpenLinks {
                guard let defaultAppCase = LinkOpener(rawValue: defaultApp) else {
                    return
                }
                
                switch defaultAppCase {
                case .safari:
                    UIApplication.shared.open(url)
                case .webview:
                    let safariVC = SFSafariViewController(url: url)
                    parentVC?.present(safariVC, animated: true)
                }
            } else {
                // Default option - if the UserDefault key does not exist, the setting was not modified
                let safariVC = SFSafariViewController(url: url)
                parentVC?.present(safariVC, animated: true)
            }
            
            
        }
    }
}
