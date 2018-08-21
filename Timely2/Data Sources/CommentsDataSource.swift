//
//  ItemsDataSource.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/26/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

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

class CommentsDataSource: NSObject, UITableViewDataSource {
    
    private var data = [Comment]()
    
    override init() {
        super.init()
    }
    
    func update(with comments: [Comment]) {
        data = comments
    }
    
    // MARK - Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        let item = data[indexPath.row]
        
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
    
}
