//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    
    var detailItem: Item?
    var fetchedComment: Comment? = nil
    typealias Depth = Int
    var commentsFlatArray: [(Comment, Depth)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.dataSource = self
        
        if let story = self.detailItem {
            //Update UI
            self.detailDescriptionLabel?.text = story.title
            self.urlDescriptionLabel?.text = story.url?.absoluteString
            print("story.id ", story.id)
            
            fetchComments(forItem: story)
            
            //Construct a 'flat' array structure of the comments by traversing the tree depth first

            
            
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchComments(forItem item: Item) {
        
        func DFS(forItem item: Comment, depth: Int) {
            if let nestedItems = item.children {
                if !nestedItems.isEmpty {
                    for nestedItem in nestedItems {
                        commentsFlatArray.append((nestedItem, depth))
                        DFS(forItem: nestedItem, depth: depth+1)
                    }
                }
            }
        }
            
        //if let item = item {
        if let kids = item.kids, kids.isEmpty == false {
            
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            configuration.httpMaximumConnectionsPerHost = 2
            let defaultSession = URLSession(configuration: configuration)
            
            
            let commentUrl = "http://hn.algolia.com/api/v1/items/\(String(item.id))"
            let commentRequest = URLRequest(url: URL(string: commentUrl)!)
            
            _ = defaultSession.dataTask(with: commentRequest) { data, response, error in
        
                let statusCode = (response as! HTTPURLResponse).statusCode
                //print(statusCode)
                if let data = data, statusCode == 200 {
                    do {
                        //print(data)
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        self.fetchedComment = try decoder.decode(Comment.self, from: data)
                        
                        if let comments = self.fetchedComment {
                            if let childrenComments = comments.children {
                                for childComment in childrenComments {
                                    self.commentsFlatArray.append((childComment, 0))
                                    DFS(forItem: childComment, depth: 1)
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
            
        }
        
    }
    
    // MARK - Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection " + String(self.commentsFlatArray.count))
        
        return self.commentsFlatArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if let and cast "as?"
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        
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
        
        return cell
    }
}
