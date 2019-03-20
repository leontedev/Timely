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

struct Story {
    var url: URL?
    var title: String?
    var author: String?
    var createdAt: Date?
    var numComments: Int?
    var points: Int?
    var text: String?
}

class StoriesDetailViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    @IBOutlet weak var commentStackView: UIStackView!
    
    private let storiesDetailDataSource = CommentsDataSource()
    var story: Story = Story()
    var comments: [CommentSource] = []
    
    var state = State.loading {
        didSet {
            debugLog()
            updateFooterView()
            
            storiesDetailDataSource.setData(parent: self, story: self.story, comments: self.comments)
            commentsTableView.reloadData()
        }
    }
    
    var officialStoryItem: Item?
    var algoliaStoryItem: AlgoliaItem?
    var fetchedComment: Comment? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        activityIndicator.color = UIColor.lightGray
        
        commentsTableView.delegate = storiesDetailDataSource
        commentsTableView.dataSource = storiesDetailDataSource
        
        if let story = self.officialStoryItem {
            //Update UI
            self.story.title = story.title
            self.story.url = story.url
            self.story.author = story.by
            self.story.createdAt = story.time
            self.story.numComments = story.descendants
            self.story.points = story.score
            self.story.text = story.text
            
            debugLog()
            if let _ = story.kids {
                fetchComments(forItemID: String(story.id))
            }
        }
        if let story = self.algoliaStoryItem {
            self.story.title = story.title
            self.story.url = story.url
            self.story.author = story.author
            self.story.createdAt = story.created_at
            self.story.numComments = story.num_comments
            self.story.points = story.points
            self.story.text = story.story_text
            
            debugLog()
            if let _ = story.num_comments {
                fetchComments(forItemID: story.objectID)
            }
        }
        
        if story.numComments == 0 {
            self.state = .empty
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
                            self.comments.append(CommentSource(comment: nestedItem,
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
        

        self.state = .loading
        
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 2
        let defaultSession = URLSession(configuration: configuration)
        
        
        let commentUrl = "https://hn.algolia.com/api/v1/items/\(storyID)"
        guard let url = URL(string: commentUrl) else {
            state = .error(HNError.badURL(fromString: commentUrl))
            return
        }
        let commentRequest = URLRequest(url: url)
        
        _ = defaultSession.dataTask(with: commentRequest) { data, response, error in
            
            if let responseError = error {
                self.state = .error(responseError)
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if let data = data, statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .customISO8601
                    self.fetchedComment = try decoder.decode(Comment.self, from: data)
                    
                    if let comments = self.fetchedComment {
                        if let childrenComments = comments.children {
                            for childComment in childrenComments {
                                if let _ = childComment.text {
                                    self.comments.append(CommentSource(comment: childComment,
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
                    
                    let options = [
                        DTCoreTextStub.kDTCoreTextOptionKeyFontSize(): NSNumber(value: Float(fontSize)),
                        DTCoreTextStub.kDTCoreTextOptionKeyFontName(): UIFont.systemFont(ofSize: 14).fontName, //"HelveticaNeue",
                        DTCoreTextStub.kDTCoreTextOptionKeyFontFamily(): UIFont.systemFont(ofSize: 14).familyName, //"Helvetica Neue",
                        DTCoreTextStub.kDTCoreTextOptionKeyUseiOS6Attributes(): NSNumber(value: true),
                        DTCoreTextStub.kDTCoreTextOptionKeyTextColor(): color] as [String? : Any]
                    
                    
                    for (index, comment) in self.comments.enumerated() {
                        
                        let epochTime = comment.comment.created_at
                        let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                        self.comments[index].timeAgo = timeAgo
                        
                        //Parse html in the .text parameter to NSAttributedString
                        //Start working on a background thread - if parsing will not be ready, it will be done 'live' when displaying the row on the main thread
//                        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                            guard let self = self else {
//                                return
//                            }
                        
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
                            
                            self.comments[index].attributedString = mutableAttributedString
                        }
                    }
                       

//                    }
                    let delta = CFAbsoluteTimeGetCurrent() - t0
                    debugLog()
                    
                    DispatchQueue.main.async {
                        self.state = .populated
                    }
                    
                    
                }
                catch let error {
                    self.state = .error(HNError.parsingJSON("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription))
                }
            } else {
                // FIXME: Attach response status code
                self.state = .error(HNError.network(String(statusCode)))
            }
            
        }.resume()

    }
    
    
    // MARK: - View Config
    
    func updateFooterView() {
        
        switch state {
            
        case .error(let error):
            errorLabel.text = error.localizedDescription
            commentsTableView.tableFooterView = errorView
        case .loading:
            commentsTableView.tableFooterView = loadingView
        //    case .paging:
        //        tableView.tableFooterView = loadingView
        case .empty:
            commentsTableView.tableFooterView = emptyView
        case .populated:
            commentsTableView.tableFooterView = nil
        }
        
    }
    
    
}


