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
    
    typealias Depth = Int
    var commentsArray: [(Item, Depth)] = []
    var commentsCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Detail Controller")
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.dataSource = self
        
        if let story = self.detailItem {
            //Update UI
            self.detailDescriptionLabel?.text = story.title
            self.urlDescriptionLabel?.text = story.url?.absoluteString
            print("story.id ", story.id)
            
            //self.commentsTableView.reloadData()
//            DispatchQueue.main.async {
//            }
            //Update self.detailItem object with comments
            fetchComments(forItem: story)
            

            //Waits for all comments to finish downloading before continuing with reloading the UI
            var count = 0
            while self.commentsCount < (self.detailItem?.descendants)! && count < 100 {
                #warning("wait for multiple async comment requests to finish")
                //0.1s
                usleep(100000)
                //print("wait 0.1s, downloaded count: " + String(self.commentsCount) + " /descendants: "  + String((self.detailItem?.descendants)!))
                count += 1
            }
            print("Total waited in seconds: " + String(Double(count)*0.1))
            
            
            //Construct a 'flat' array structure of the comments by traversing the tree depth first
            if let comments = story.kids {
                for comment in comments {
                    commentsArray.append((comment, 0))
                    DFS(forItem: comment, depth: 1)
                }
            }
            
            //DispatchQueue.main.async {
            //self.commentsTableView.reloadData()
        }
    }
    
    func DFS(forItem item: Item, depth: Int) {
        if let nestedItems = item.kids, !nestedItems.isEmpty {
            for nestedItem in nestedItems {
                commentsArray.append((nestedItem, depth))
                DFS(forItem: nestedItem, depth: depth+1)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchComments(forItem item: Item) {
        //if let item = item {
        if let kids = item.kids, kids.isEmpty == false {
            
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            configuration.httpMaximumConnectionsPerHost = 2
            let defaultSession = URLSession(configuration: configuration)
            
            for item in kids {
                let commentUrl = "https://hacker-news.firebaseio.com/v0/item/\(String(item.id)).json"
                let commentRequest = URLRequest(url: URL(string: commentUrl)!)
                
                let taskComment = defaultSession.dataTask(with: commentRequest) { data, response, error in
                    #warning("Thread 12: Fatal error: Unexpectedly found nil while unwrapping an Optional value")
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    self.commentsCount += 1
                    
                    if let data = data, statusCode == 200 {
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .secondsSince1970
                            let comment = try decoder.decode(Item.self, from: data)
                            
                            if let deleted = comment.deleted {
                                //print(".deleted comment")
                            }
                            self.detailItem?.update(withComment: comment)
                            self.fetchComments(forItem: comment)
                        }
                        catch let error {
                            print("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription)
                            print(error)
                            #warning("Handle UI here")
                        }
                    }
                    
                }.resume()
                let d = Date()
                let df = DateFormatter()
                df.dateFormat = "H:m:ss.SSSS"
                
                print(item.id, " ", df.string(from: d))
            }
        }  else {
            return
        }
        
    }
    
    // MARK - Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #warning("Remove Force Unwrap. And check if count is correct - do you need to ignore certain comments (dead, etc)")
        print("numberOfRowsInSection " + String(self.commentsArray.count))
        return self.commentsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if let and cast "as?"
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        
        let item = self.commentsArray[indexPath.row].0
        let depth = self.commentsArray[indexPath.row].1
                
        // Indent cell based on comment depth
        cell.indentationWidth = 15
        cell.indentationLevel = Int(depth)
        
        // Indent the separator line between the cells
        let separatorIndent = CGFloat(15 + Int(cell.indentationWidth) * Int(cell.indentationLevel))
        cell.separatorInset = UIEdgeInsetsMake(0, separatorIndent, 0, 0)
        
        cell.commentLabel?.text = item.text?.htmlToString
        cell.byUserLabel?.text = item.by
        //cell.depthLabel?.text = String(depth)
        
        // Display elapsed time
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        componentsFormatter.maximumUnitCount = 1
        componentsFormatter.unitsStyle = .abbreviated
        if let epochTime = item.time {
            let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
            cell.elapsedTimeLabel?.text = timeAgo
        }
        return cell
    }
}
