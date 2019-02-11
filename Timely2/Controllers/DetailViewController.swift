//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

struct CommentSource {
    var comment: Comment
    var depth: Int
    var timeAgo: String?
    var height: Int?
    var collapsed: Bool
    var removedComments: [CommentSource]
    var attributedString: NSAttributedString?
}

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    @IBOutlet weak var commentStackView: UIStackView!
    
    
    var detailItem: Item?
    var algoliaItem: AlgoliaItem?
    
    var fetchedComment: Comment? = nil
    typealias Depth = Int
    //var commentsFlatArray: [(Comment, Depth)] = []
    var commentsArray: [CommentSource] = []
    
    let STORY_CELL_SECTION = 0
    let STORY_BUTTONS_CELL_SECTION = 1
    let COMMENT_CELL_SECTION = 2
    
    var storyURL: URL? = nil
    var storyTitle: String? = nil
    var storyAuthor: String? = nil
    var storyCreatedAt: Date? = nil
    var storyNumComments: Int? = nil
    var storyPoints: Int? = nil
    var storyText: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.dataSource = self
        
        if let story = self.detailItem {
            //Update UI
            self.storyTitle = story.title
            self.storyURL = story.url
            self.storyAuthor = story.by
            self.storyCreatedAt = story.time
            self.storyNumComments = story.descendants
            self.storyPoints = story.score
            self.storyText = story.text
            
            print("story.id ", story.id)
            if let _ = story.kids {
                fetchComments(forItemID: String(story.id))
            }
        }
        if let story = self.algoliaItem {
            self.storyTitle = story.title
            self.storyURL = story.url
            self.storyAuthor = story.author
            self.storyCreatedAt = story.created_at
            self.storyNumComments = story.num_comments
            self.storyPoints = story.points
            self.storyText = story.story_text
            
            print("story.id ", story.objectID)
            if let _ = story.num_comments {
                fetchComments(forItemID: story.objectID)
            }
        }
        
        
    
    }
    
    @objc func labelTapped(sender:UITapGestureRecognizer) {
        if let url = storyURL {
            UIApplication.shared.open(url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchComments(forItemID storyID: String) {
        
        func DFS(forItem item: Comment, depth: Int) {
            if let nestedItems = item.children {
                if !nestedItems.isEmpty {
                    for nestedItem in nestedItems {
                        if let _ = nestedItem.text {
                            //commentsFlatArray.append((nestedItem, depth))
                            self.commentsArray.append(CommentSource(comment: nestedItem,
                                                                    depth: depth,
                                                                    timeAgo: nil,
                                                                    height: nil,
                                                                    collapsed: false,
                                                                    removedComments: [],
                                                                    attributedString: nil))
                            DFS(forItem: nestedItem, depth: depth+1)
                        }
                    }
                }
            }
        }
        
            
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 2
        let defaultSession = URLSession(configuration: configuration)
        
        
        let commentUrl = "http://hn.algolia.com/api/v1/items/\(storyID)"
        let commentRequest = URLRequest(url: URL(string: commentUrl)!)
        
        _ = defaultSession.dataTask(with: commentRequest) { data, response, error in
    
            let statusCode = (response as! HTTPURLResponse).statusCode
            //print(statusCode)
            if let data = data, statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .customISO8601
                    self.fetchedComment = try decoder.decode(Comment.self, from: data)
                    
                    if let comments = self.fetchedComment {
                        if let childrenComments = comments.children {
                            for childComment in childrenComments {
                                if let _ = childComment.text {
                                    self.commentsArray.append(CommentSource(comment: childComment,
                                                                            depth: 0,
                                                                            timeAgo: nil,
                                                                            height: nil,
                                                                            collapsed: false,
                                                                            removedComments: [], attributedString: nil))
                                    DFS(forItem: childComment,
                                        depth: 1)
                                }
                                
                            }
                        }
                    }
                    let t0 = CFAbsoluteTimeGetCurrent()
                    let componentsFormatter = DateComponentsFormatter()
                    //Parse the Date to String representing 'Elapsed Time'
                    componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                    componentsFormatter.maximumUnitCount = 1
                    componentsFormatter.unitsStyle = .abbreviated
                    
                    //HTML Parsing / Attributed String Options
                    let color = UIColor.black
                    let fontSize: Float = 14
                    
                    var options = [
                        DTCoreTextStub.kDTCoreTextOptionKeyFontSize(): NSNumber(value: Float(fontSize)),
                        DTCoreTextStub.kDTCoreTextOptionKeyFontName(): UIFont.systemFont(ofSize: 14).fontName, //"HelveticaNeue",
                        DTCoreTextStub.kDTCoreTextOptionKeyFontFamily(): UIFont.systemFont(ofSize: 14).familyName, //"Helvetica Neue",
                        DTCoreTextStub.kDTCoreTextOptionKeyUseiOS6Attributes(): NSNumber(value: true),
                        DTCoreTextStub.kDTCoreTextOptionKeyTextColor(): color] as [String? : Any]
                    
                    
                    for (index, comment) in self.commentsArray.enumerated() {
                        
                        let epochTime = comment.comment.created_at
                        let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                        self.commentsArray[index].timeAgo = timeAgo
                        
                        //Parse html in the .text parameter to NSAttributedString
                        //Start working on a background thread - if parsing will not be ready, it will be done 'live' when displaying the row on the main thread
                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            if let commentText = comment.comment.text {
                                guard let attributedString = DTCoreTextStub.attributedString(withHtml: commentText, options: options) else {
                                    return
                                }
                                
                                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString.trimmingCharacters(in: .whitespacesAndNewlines))
                                
                                let range = NSMakeRange(0, attributedString.length)
                                mutableAttributedString.mutableString.replaceOccurrences(of: "\n\n", with: "\n", options: NSString.CompareOptions.caseInsensitive, range: range)
                                
//                                var style = NSMutableParagraphStyle()
//                                style.lineSpacing = 3.5
//                                mutableAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
                                
                                self.commentsArray[index].attributedString = mutableAttributedString
                            }
                        }
                       

                    }
                    let delta = CFAbsoluteTimeGetCurrent() - t0
                    print("#LOG Date Formatting & starting HTML Parsing (on a background thread) took \(delta) seconds")
                    
                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                    
                    
                }
                catch let error {
                    print("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription)
                    print(error)
                    // TODO: #warning("Handle UI here")
                }
            }
            
        }.resume()

    }
    
    // MARK - Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == COMMENT_CELL_SECTION {
            print("numberOfRowsInSection " + String(self.commentsArray.count))
            return self.commentsArray.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommentCell!
        
        if indexPath.section == COMMENT_CELL_SECTION {
        
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierComment, for: indexPath) as? CommentCell

            let item = self.commentsArray[indexPath.row].comment
            let depth = self.commentsArray[indexPath.row].depth
            
            // Indent cell based on comment depth
            let indent = CGFloat(depth) * 15
            cell.commentStackView.layoutMargins = UIEdgeInsets(top: 0, left: indent, bottom: 0, right: 0)
            cell.commentStackView.isLayoutMarginsRelativeArrangement = true
            //cell.indentationWidth = 15
            //cell.indentationLevel = Int(depth)
            
            // Indent the separator line between the cells
            let separatorIndent = CGFloat(15 + indent)
            cell.separatorInset = UIEdgeInsetsMake(0, separatorIndent, 0, 0)
            

            if let attributedString = self.commentsArray[indexPath.row].attributedString {
                // cell.commentLabel?.attributedText = attributedString
                cell.commentTextView?.attributedText = attributedString
                //print("#LOG Text was already parsed")
            } else {
                print("#LOG Parsed text not found. Parsing on the Main Thread.")
                if let commentText = item.text {
                    
                    // cell.commentLabel.attributedText = commentText.htmlToAttributedString
                    cell.commentTextView.attributedText = commentText.htmlToAttributedString
                }
            }
            
            cell.byUserLabel?.text = item.author
            cell.elapsedTimeLabel?.text = self.commentsArray[indexPath.row].timeAgo
            
        } else if indexPath.section == STORY_CELL_SECTION {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierStory, for: indexPath) as? CommentCell
            
            if let title = self.storyTitle {
                cell.titleLabel.text = title
            }
            
            if let url = self.storyURL {
                cell.urlLabel.text = url.absoluteString
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.labelTapped))
                cell.urlLabel.isUserInteractionEnabled = true
                cell.urlLabel.addGestureRecognizer(tap)
            }
            
            if let author = self.storyAuthor {
                cell.storyUsernameLabel.text = author
            }
            
            if let createdAt = self.storyCreatedAt {
                let componentsFormatter = DateComponentsFormatter()
                componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                componentsFormatter.maximumUnitCount = 1
                componentsFormatter.unitsStyle = .abbreviated
                
                let timeAgo = componentsFormatter.string(from: createdAt, to: Date())
                cell.storyElapsedLabel.text = timeAgo
            }
            
            if let numComments = self.storyNumComments {
                cell.storyNumComments.text = String(numComments)
                
            }
            
            if let points = self.storyPoints {
                cell.storyPoints.text = String(points)
            }
            
            if let text = self.storyText {
                cell.storyText.attributedText = text.htmlToAttributedString
            }
            
        } else if indexPath.section == STORY_BUTTONS_CELL_SECTION {
            
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierStoryButtons, for: indexPath) as? CommentCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == COMMENT_CELL_SECTION {
            if !self.commentsArray[indexPath.row].collapsed {
                
                let selectedItemDepth = self.commentsArray[indexPath.row].depth
            
                //self.collapsedCellsIndexPaths.append(indexPath)
                self.commentsArray[indexPath.row].height = 28
                self.commentsArray[indexPath.row].collapsed = true
                
                // Find all the child comments
                var index = indexPath.row + 1
                var childCommentsForRemoval: [IndexPath] = []
                while index < self.commentsArray.count && self.commentsArray[index].depth > selectedItemDepth {
                    // Construct the array of removed Comments to be able to retrieve them on Expanding the collapsed comment tree
                    self.commentsArray[indexPath.row].removedComments.append(self.commentsArray[index])
                    // FIXME: [IndexPath] for rows to be deleted
                    childCommentsForRemoval.append(IndexPath(row: index, section: COMMENT_CELL_SECTION))
                    
                    index = index + 1
                }
                
                if childCommentsForRemoval.count > 0 {
                    
                    for childComment in childCommentsForRemoval.sorted(by: >) {
                        self.commentsArray.remove(at: childComment.row)
                    }
                    
                    self.commentsTableView.performBatchUpdates({
                        self.commentsTableView.deleteRows(at: childCommentsForRemoval, with: UITableViewRowAnimation.bottom)
                    }, completion: nil)
                }
            
                //these tell the tableview something changed, and it checks cell heights and animates changes
                self.commentsTableView.beginUpdates()
                self.commentsTableView.endUpdates()
            } else {
                self.commentsArray[indexPath.row].height = nil
                self.commentsArray[indexPath.row].collapsed = false
                
                if self.commentsArray[indexPath.row].removedComments.count > 0 {
                    //re-insert the previously removed child comments (with higher depths)
                    self.commentsArray.insert(contentsOf: self.commentsArray[indexPath.row].removedComments, at: indexPath.row + 1)
                    
                    var indexPaths: [IndexPath] = []
                    for (index, _) in self.commentsArray[indexPath.row].removedComments.enumerated() {
                        indexPaths.append(IndexPath(row: index + indexPath.row + 1, section: COMMENT_CELL_SECTION))
                    }
                    self.commentsTableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
                    self.commentsArray[indexPath.row].removedComments.removeAll()
                    
                }
                self.commentsTableView.beginUpdates()
                self.commentsTableView.endUpdates()
                
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == COMMENT_CELL_SECTION && self.commentsArray.count > 0 {
            if let height = self.commentsArray[indexPath.row].height {
                return CGFloat(integerLiteral: height)
            }
        }
        return UITableViewAutomaticDimension
    }

    
}
