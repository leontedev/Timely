//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    
    var detailItem: Item?
    var algoliaItem: AlgoliaItem?
    
    var fetchedComment: Comment? = nil
    typealias Depth = Int
    var commentsFlatArray: [(Comment, Depth)] = []
    
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
                            commentsFlatArray.append((nestedItem, depth))
                            DFS(forItem: nestedItem, depth: depth+1)
                        }
                    }
                }
            }
        }
            
        //if let item = item {
        //if let kids = item.kids, kids.isEmpty == false {
            
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
                                    self.commentsFlatArray.append((childComment, 0))
                                    DFS(forItem: childComment, depth: 1)
                                }
                                
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                    
                }
                catch let error {
                    print("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription)
                    print(error)
                    #warning("Handle UI here")
                }
            }
            
        }.resume()
            
        //}
        
    }
    
    // MARK - Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == COMMENT_CELL_SECTION {
            print("numberOfRowsInSection " + String(self.commentsFlatArray.count))
            return self.commentsFlatArray.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CommentCell!
        
        if indexPath.section == COMMENT_CELL_SECTION {
        
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierComment, for: indexPath) as! CommentCell
            
            let item = self.commentsFlatArray[indexPath.row].0
            let depth = self.commentsFlatArray[indexPath.row].1
            
            // Indent cell based on comment depth
            cell.indentationWidth = 15
            cell.indentationLevel = Int(depth)
            
            // Indent the separator line between the cells
            let separatorIndent = CGFloat(15 + Int(cell.indentationWidth) * Int(cell.indentationLevel))
            cell.separatorInset = UIEdgeInsetsMake(0, separatorIndent, 0, 0)
            
            cell.commentLabel?.text = item.text?.htmlToString
            cell.byUserLabel?.text = item.author
            //cell.depthLabel?.text = String(depth)
            
            // Display elapsed time
            let componentsFormatter = DateComponentsFormatter()
            componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
            componentsFormatter.maximumUnitCount = 1
            componentsFormatter.unitsStyle = .abbreviated
            let epochTime = item.created_at
            let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
            cell.elapsedTimeLabel?.text = timeAgo
            
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
                cell.storyText.text = text.htmlToString
            }
            
        } else if indexPath.section == STORY_BUTTONS_CELL_SECTION {
            cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifierStoryButtons, for: indexPath) as? CommentCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == COMMENT_CELL_SECTION {
            
            let selectedItem = self.commentsFlatArray[indexPath.row].0
            let selectedItemDepth = self.commentsFlatArray[indexPath.row].1
            
            self.collapsedCellsIndexPaths.append(indexPath)
            
            // Find all the child comments, and add them to the hiddenCells array
            var index = indexPath.row + 1
            while self.commentsFlatArray[index].1 > selectedItemDepth {
                self.hiddenCellsIndexPaths.append(IndexPath(row: index, section: COMMENT_CELL_SECTION))
                index = index + 1
            }
            
            //these tell the tableview something changed, and it checks cell heights and animates changes
            self.commentsTableView.beginUpdates()
            self.commentsTableView.endUpdates()
        }
        
        
    }
    
    internal var hiddenCellsIndexPaths: [IndexPath] = []
    internal var collapsedCellsIndexPaths: [IndexPath] = []
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.collapsedCellsIndexPaths.contains(indexPath) {
            let size = CGFloat(integerLiteral: 25)
            
            return size
        } else if self.hiddenCellsIndexPaths.contains(indexPath) {
            let size = CGFloat(integerLiteral: 0)
            
            return size
        } else {
            return UITableViewAutomaticDimension
        }
    }

    
}
