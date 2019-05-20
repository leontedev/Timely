//
//  DetailViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit


class CommentsViewController: UIViewController {
  
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var emptyView: UIView!
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var detailDescriptionLabel: UILabel!
  @IBOutlet weak var urlDescriptionLabel: UILabel!
  @IBOutlet weak var commentStackView: UIStackView!
  
  private let dataSource = CommentsDataSource()
  
  let AlgoliaClient = AlgoliaAPIClient()
  var algoliaStoryItem: Story?
  var fetchedComment: Comment? = nil

  var comments: [CommentSource] = []
  
  var state = State.loading {
    didSet {
      updateFooterView()
      
      guard let story = algoliaStoryItem else { return }
      
      dataSource.setData(parent: self, story: story, comments: self.comments)
      tableView.reloadData()
    }
  }
  
  var isSetToUseCustomFontForComments: Bool { return UserDefaults.standard.bool(forKey: "isSetToUseCustomFontForComments") }
  var customFontSizeComments: Float { return UserDefaults.standard.float(forKey: "customFontSizeComments") }
  var prefferedFontSize: UIFont {
    
    if isSetToUseCustomFontForComments {
      let font = UIFont.systemFont(ofSize: CGFloat(customFontSizeComments))
      return UIFontMetrics.default.scaledFont(for: font)
    } else {
      return .preferredFont(forTextStyle: .body)
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    activityIndicator.color = UIColor.lightGray
    
    tableView.delegate = dataSource
    tableView.dataSource = dataSource
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fontSizeDidModify),
                                           name: .commentsLabelAppearanceChangingFinished,
                                           object: nil
    )
    
    
    guard let story = self.algoliaStoryItem else { return }

    if story.num_comments == 0 {
      self.state = .empty
    } else {
      
      self.state = .loading
    
      AlgoliaClient.fetchComments(forItemID: story.objectID) { commentsResult in
        
        switch commentsResult {
        case .success(let fetchedComments):
          self.comments = fetchedComments
          self.state = .populated
        case .failure(let error):
          self.state = .error(error)
        }
        
      }
      
    }
    
  }
    
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func fontSizeDidModify(_ notification: Notification) {
    
    //print("Comments font size should modify to \(prefferedFontSize)")
    
    for (index, comment) in self.comments.enumerated() {
      if let attributedString = comment.attributedString {
        var mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        mutableAttributedString.replaceFont(font: self.prefferedFontSize)
        
        self.comments[index].attributedString = mutableAttributedString
      }
    }
    
    guard let story = self.algoliaStoryItem else { return }
    
    dataSource.setData(parent: self, story: story, comments: self.comments)
    
    tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - View Config
  
  func updateFooterView() {
    
    switch state {
      
    case .error(let error):
      errorLabel.text = error.localizedDescription
      tableView.tableFooterView = errorView
    case .loading:
      tableView.tableFooterView = loadingView
      //    case .paging:
    //        tableView.tableFooterView = loadingView
    case .empty:
      tableView.tableFooterView = emptyView
    case .populated:
      tableView.tableFooterView = nil
    }
    
  }
  
  
}


