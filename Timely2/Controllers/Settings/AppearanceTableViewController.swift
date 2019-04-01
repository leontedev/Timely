//
//  AppearanceTableViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/8/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

extension Notification.Name {
    // to update continuously the font size of the label storiesSystemFontLabel: "Use System Font Size" in this View
    static var storiesLabelAppearanceChanged: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.storiesLabelAppearanceChanged")
    }
    
    // to update the Stories ItemCell font size, once, after the stories slider is released with the final value
    static var storiesLabelAppearanceChangingFinished: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.storiesLabelAppearanceChangingFinished")
    }
    
    // to update continuously the font size of the label commentsSystemFontLabel: "Use System Font Size" in this View
    static var commentsLabelAppearanceChanged: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.commentsLabelAppearanceChanged")
    }
    
    // to update the Comments attributed string, once, after the comments slider is released with the final value
    static var commentsLabelAppearanceChangingFinished: Notification.Name {
        return .init(rawValue: "AppearanceTableViewController.commentsLabelAppearanceChangingFinished")
    }
}


class AppearanceTableViewController: UITableViewController {
    
    private let notificationCenter = NotificationCenter.default
    
    // If the userdefault was never previously set it will return false (which coincides with the default configuration - to use the system font)
    var isSetToUseCustomFontForStories: Bool = UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForStories") {
        didSet {
            UserDefaults.standard.set(isSetToUseCustomFontForStories, forKey: "isSetToUseCustomFontForStories")
        }
    }
    
    // Default value is 17
    var customFontSizeStories: Float = UserDefaults.standard.float(forKey: "customFontSizeStories") == 0 ? Float(17) : UserDefaults.standard.float(forKey: "customFontSizeStories") {
        didSet {
            UserDefaults.standard.set(customFontSizeStories, forKey: "customFontSizeStories")
        }
    }
    
    var isSetToUseCustomFontForComments: Bool = UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForComments") {
        didSet {
            UserDefaults.standard.set(isSetToUseCustomFontForComments, forKey: "isSetToUseCustomFontForComments")
        }
    }
    
    // Default value is 14.
    var customFontSizeComments: Float = UserDefaults.standard.float(forKey: "customFontSizeComments") == 0 ? Float(14) : UserDefaults.standard.float(forKey: "customFontSizeComments") {
        didSet {
            UserDefaults.standard.set(customFontSizeComments, forKey: "customFontSizeComments")
        }
    }
    
    
    @IBOutlet weak var storiesSystemFontSwitch: UISwitch!
    @IBOutlet weak var storiesSystemFontLabel: UILabel!
    @IBOutlet weak var storiesFontSizeSlider: UISlider!
    @IBOutlet weak var commentsSystemFontSwitch: UISwitch!
    @IBOutlet weak var commentsSystemFontLabel: UILabel!
    @IBOutlet weak var commentsFontSizeSlider: UISlider!
    
    
    @IBAction func toggleStoriesSwitchUseSystemFont(_ sender: Any) {
        isSetToUseCustomFontForStories = !storiesSystemFontSwitch.isOn
        updateStoriesUI()
        notificationCenter.post(name: .storiesLabelAppearanceChangingFinished, object: nil)
    }
    
    @IBAction func dragStoriesSliderFontSize(_ sender: Any) {
        if let newSliderPosition = storiesFontSizeSlider {
            customFontSizeStories = newSliderPosition.value
            updateStoriesUI()
            //notificationCenter.post(name: .storiesLabelAppearanceChanged, object: nil)
        }
    }
    
    @IBAction func finishedDraggingStoriesSliderFontSize(_ sender: Any) {
        notificationCenter.post(name: .storiesLabelAppearanceChangingFinished, object: nil)
    }
    
    
    @IBAction func toggleCommentsSwitchUseSystemFont() {
        isSetToUseCustomFontForComments = !commentsSystemFontSwitch.isOn
        updateCommentsUI()
        notificationCenter.post(name: .commentsLabelAppearanceChangingFinished, object: nil)
    }
    
    @IBAction func dragCommentsSliderFontSize() {
        if let newSliderPosition = commentsFontSizeSlider {
            customFontSizeComments = newSliderPosition.value
            updateCommentsUI()
            //notificationCenter.post(name: .commentsLabelAppearanceChanged, object: nil)
        }
    }
    
    @IBAction func finishedDraggingCommentsSliderFontSize(_ sender: Any) {
        notificationCenter.post(name: .commentsLabelAppearanceChangingFinished, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatically resize when font changes are initiated
        storiesSystemFontLabel.adjustsFontForContentSizeCategory = true
        commentsSystemFontLabel.adjustsFontForContentSizeCategory = true
        
        // Initial config of the UISlider with the position saved in UserDefaults
        storiesFontSizeSlider.setValue(customFontSizeStories, animated: false)
        commentsFontSizeSlider.setValue(customFontSizeComments, animated: false)
        
        // Initial config of the stories label font size, UISwitch on/off and if the UISlider is enabled
        updateStoriesUI()
        updateCommentsUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func updateStoriesUI() {
        // Configure the Switch toggle
        storiesSystemFontSwitch.setOn(!isSetToUseCustomFontForStories, animated: false)
        
        if isSetToUseCustomFontForStories {
            let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeStories))
            storiesSystemFontLabel.font = UIFontMetrics.default.scaledFont(for: font)
            //storiesSystemFontLabel.font = storiesSystemFontLabel.font.withSize(CGFloat(customFontSizeStories))
            
            storiesFontSizeSlider.isEnabled = true
        } else {
            storiesSystemFontLabel.font = .preferredFont(forTextStyle: .body)
            storiesFontSizeSlider.isEnabled = false
        }
    }
    
    func updateCommentsUI() {
        // Configure the Switch toggle
        commentsSystemFontSwitch.setOn(!isSetToUseCustomFontForComments, animated: false)
        
        if isSetToUseCustomFontForComments {
            let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeComments))
            commentsSystemFontLabel.font = UIFontMetrics.default.scaledFont(for: font)
            //commentsSystemFontLabel.font = commentsSystemFontLabel.font.withSize(CGFloat(customFontSizeComments))
            commentsFontSizeSlider.isEnabled = true
        } else {
            commentsSystemFontLabel.font = .preferredFont(forTextStyle: .body)
            commentsFontSizeSlider.isEnabled = false
        }
    }

}
