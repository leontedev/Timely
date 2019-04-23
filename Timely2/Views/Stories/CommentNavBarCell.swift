//
//  CommentNavBarCell.swift
//  Timely2
//
//  Created by Mihai Leonte on 4/2/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit
import SafariServices

class CommentNavBarCell: UITableViewCell {
    
    var shareItems: [Any] = []
    var storyURL: URL?
    var storyID: String? {
        didSet {
            guard let storyID = storyID else { return }
            if Bookmarks.shared.contains(id: storyID) {
                isBookmarked = true
            }
        }
    }
    weak var parentVC: UIViewController?
    static let reuseIdentifier = "StoryButtonsCell"
    var isBookmarked: Bool = false {
        didSet {
            saveBookmarkButton.isSelected = isBookmarked
        }
    }

    
    @IBOutlet weak var saveBookmarkButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBAction func safariButtonPressed() {
        if let url = storyURL {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func webviewButtonPressed() {
        showSafariVC(for: self.storyURL)
    }
    
    @IBAction func shareButtonPressed() {
        displayShareSheet()
    }
    
    @IBAction func saveBookmarkPressed(_ sender: Any) {
        guard let storyID = storyID else { return }
        
        if isBookmarked {
            Bookmarks.shared.remove(id: storyID)
        } else {
            Bookmarks.shared.add(id: storyID)
        }
        
        isBookmarked.toggle()
        
    }
    
    func showSafariVC(for url: URL?) {
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            if let detailViewController = parentVC {
                detailViewController.present(safariVC, animated: true)
            }
        }
    }
    
    func displayShareSheet() {
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        if let detailViewController = parentVC {
            detailViewController.present(activityViewController, animated: true)
        }
    }
}
