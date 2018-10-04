//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var urlDescriptionLabel: UILabel!
    
    var detailItem: Item?
    var comments: [Item] = []
    //let dataSource = CommentsDataSource()
    var fetchedComments: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.dataSource = self.dataSource
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        // Update the user interface for the detail item.
        if let item = detailItem {
            
            detailDescriptionLabel?.text = item.title
            urlDescriptionLabel?.text = item.url?.absoluteString
            
            if let kids = item.kids, kids.isEmpty == false {
                for kid in item.kids {
                    getComments(from: kid)
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
    
    func getComments() {
        
    }

}

// MARK - Data Source

func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedComments.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
    let item = fetchedComments[indexPath.row]
    
    cell.commentLabel?.text = item.text?.htmlToString
    cell.byUserLabel?.text = item.by
    cell.depthLabel?.text = String(item.depth)
    
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

// MARK - Helper methods
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
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
