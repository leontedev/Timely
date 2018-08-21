//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class DetailViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    
    var detailItem: Item?
    var comments: [Comment] = []
    let dataSource = CommentsDataSource()
    var fetchedComments: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.dataSource = self.dataSource
        
        
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        //commentsTableView.reloadData() //it executes before the closure fetches the comments
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let item = detailItem {
            
            detailDescriptionLabel?.text = item.title
            urlDescriptionLabel?.text = item.url?.absoluteString
            
            if item.kids.isEmpty == false {
                for commentItem in item.kids {
                    getComments(from: commentItem)
                }
            }
            
//            var refreshCount = 0
//            if let commentsCount = item.descendants {
//                while (commentsCount > comments.count && refreshCount < 10) {
//
//                    self.dataSource.update(with: self.comments)
//                    self.commentsTableView.reloadData()
//
//                    refreshCount += 1
//
//                }
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//                    // Put your code which should be executed with a delay here
//                    self.dataSource.update(with: self.comments)
//                    self.commentsTableView.reloadData()
//                })
//            }
        }
    }
    
    func getComments(from commentItem: Item) {
        self.fetchItem(item: commentItem) { finished in
            print("\(commentItem.id)") // DEBUG
            if commentItem.kids.isEmpty == false {
                for comment in commentItem.kids {
                    self.getComments(from: comment)
                }
            }
            
            self.comments = []
            self.depthFirst(forItems: (self.detailItem?.kids)!, withDepth: 0)
            //if self.comments.count > 3 || self.comments.count == self.detailItem?.descendants {
            self.dataSource.update(with: self.comments)
            self.commentsTableView.reloadData()
            
        }
    }
    
    
    // MARK: - Fetch Data Functions
    
    func fetchItem(item: Item, completion: @escaping (Bool?) -> Void ) {
        
        guard let item_URL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(item.id).json") else {
            completion(nil)
            return
        }
        
        Alamofire.request(item_URL,
                          method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching HN Item")
                    completion(nil)
                    return
                }
                
                let json = JSON(response.result.value as Any)
                
                if let deleted = json["deleted"].bool {
                    if deleted {
                        completion(nil)
                    }
                }
                
                item.text = json["text"].stringValue
                item.by = json["by"].stringValue
                
                let unixtime = json["time"].doubleValue
                let convertedTime = Date(timeIntervalSince1970: unixtime)
                item.time = convertedTime
                
                let kids = json["kids"].arrayValue.map { kidID in
                    return Item(id: kidID.intValue)
                }
                item.kids = kids
                
                completion(true)
        }
    }
    
    // MARK: - Helper functions
    
    func depthFirst(forItems items: [Item], withDepth depth: Int8) {
        for item in items {
            comments.append(Comment(text: item.text, depth: depth, by: item.by, time: item.time))
            if item.kids.count > 0 {
                depthFirst(forItems: item.kids, withDepth: depth + 1)
            }
        }
    }

}

