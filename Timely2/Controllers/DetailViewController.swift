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
//    var comments: [Item] = []
//    let dataSource = CommentsDataSource()
//    var fetchedComments: [Item] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        commentsTableView.delegate = self
//        commentsTableView.estimatedRowHeight = 100
//        commentsTableView.rowHeight = UITableViewAutomaticDimension
//        commentsTableView.dataSource = self.dataSource
//        
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        configureView()
//        //commentsTableView.reloadData() //it executes before the closure fetches the comments
//        
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    func configureView() {
//        // Update the user interface for the detail item.
//        if let item = detailItem {
//            
//            detailDescriptionLabel?.text = item.title
//            urlDescriptionLabel?.text = item.url?.absoluteString
//            
//            if item.kids.isEmpty == false {
//                for commentItem in item.kids {
//                    getComments(from: commentItem)
//                }
//            }
//            
////            var refreshCount = 0
////            if let commentsCount = item.descendants {
////                while (commentsCount > comments.count && refreshCount < 10) {
////
////                    self.dataSource.update(with: self.comments)
////                    self.commentsTableView.reloadData()
////
////                    refreshCount += 1
////
////                }
////            } else {
////                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
////                    // Put your code which should be executed with a delay here
////                    self.dataSource.update(with: self.comments)
////                    self.commentsTableView.reloadData()
////                })
////            }
//        }
//    }
    

}

