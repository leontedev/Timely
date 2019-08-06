//
//  MasterViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//


import UIKit


class StoriesChildViewController: UITableViewController {
    
    // State Outlets
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    private let storiesDataSource = StoriesDataSource()
    
    var state = State.loading {
        didSet {
            self.updateFooterView()
            
            guard let currentSelectedSourceAPI = currentSelectedSourceAPI else { return }
            
            storiesDataSource.update(
                algoliaStories: stories,
                parentType: parentType
            )
            tableView.reloadAndScrollToFirstRow()
        }
    }
    
    var defaultSession: URLSession = URLSession(configuration: .default)
    var currentSelectedSourceAPI: HNFeedType?
    var currentSelectedFeedURL: URLComponents? //= URLComponents(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
    
    var stories: [Story] = []
    var storyIDs: [String] = []
  

    // Stories, Bookmarks or History?
    var parentType: ParentStoriesChildViewController?
    
    let AlgoliaClient = AlgoliaAPIClient()
    let OfficialClient = HNOfficialAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (self.parent as? StoriesViewController) != nil {
            parentType = .stories
        } else if (self.parent as? BookmarksViewController) != nil {
            parentType = .bookmarks
        } else if (self.parent as? HistoryViewController) != nil {
            parentType = .history
        }

        
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableView.automaticDimension
        
        activityIndicator.color = UIColor.lightGray
        setUpPullToRefresh()
        
        storiesDataSource.delegate = self
        self.tableView.dataSource = storiesDataSource
        self.tableView.delegate = storiesDataSource
      
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fontSizeDidModify),
                                               name: .storiesLabelAppearanceChangingFinished,
                                               object: nil
        )
        
        
        guard let parentType = parentType else { return }
        if parentType == .bookmarks {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshBookmarks),
                                                   name: .bookmarkAdded,
                                                   object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshBookmarks),
                                                   name: .bookmarkRemoved,
                                                   object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshTableRow),
                                                   name: .historyItemRemoved,
                                                   object: nil
            )
        } else if parentType == .history {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshHistory),
                                                   name: .historyAdded,
                                                   object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshHistory),
                                                   name: .historyItemRemoved,
                                                   object: nil
            )
        } else if parentType == .stories {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(fetchStories),
                                                   name: .historyCleared,
                                                   object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshTableRow),
                                                   name: .historyItemRemoved,
                                                   object: nil
            )
        }
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func refreshTableRow(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @objc private func fontSizeDidModify(_ notification: Notification) {
        tableView.reloadData()
    }
    
    /// Initiate updating the Stories TableView based on the currently selected Feed (title, feedType/currentSourceAPI and feedURL)
    @objc func fetchStories() {
        
        guard let currentSelectedSourceAPI = currentSelectedSourceAPI else { return }
        guard let currentSelectedFeedURL = currentSelectedFeedURL else { return }
      
        self.stories.removeAll()
        self.state = .loading
        
        switch currentSelectedSourceAPI {
            
        case .official:
            
            self.OfficialClient.fetchOfficialApiStoryIds(from: currentSelectedFeedURL) { officialStoriesResult in
              switch officialStoriesResult {
              case .success(let officialStories):
                
                self.AlgoliaClient.fetchStories(for: officialStories, completion: { algoliaResult in
                  switch algoliaResult {
                  case .success(let hits):
                    self.stories = hits
                    self.state = .populated
                  case .failure(let error):
                    self.state = .error(error)
                  }
                })
                
              case .failure(let error):
                self.state = .error(error)
              }
          }
          
        case .algolia:
          
            self.AlgoliaClient.fetchStories(from: currentSelectedFeedURL) { algoliaResult in
              switch algoliaResult {
              case .success(let hits):
                self.stories = hits
                self.state = .populated
              case .failure(let error):
                self.state = .error(error)
              }
          }
        }

    }
    
    /// Sets up Pull To Refresh - and calls refreshData()
    func setUpPullToRefresh() {
        let myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        myRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.tableView.refreshControl = myRefreshControl
    }
    
    // FIXME: Defect use Refresh Control animation instead of the state.loading animation
    @objc func refreshData(sender: UIRefreshControl) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.warning)
        
        guard let sourceParent = parentType else { return }
        
        switch sourceParent {
        case .stories:
            fetchStories()
        case .bookmarks:
            refreshBookmarks()
        case .history:
            refreshHistory()
        }

        sender.endRefreshing()
    }
    
    // TODO: use only one function instead of both refreshBookmarks and refreshHistory
    @objc func refreshBookmarks() {
        self.stories.removeAll()
        self.state = .loading
        
        if Bookmarks.shared.items.isEmpty {
            self.state = .empty
        } else {
            self.AlgoliaClient.fetchStories(for: Bookmarks.shared.sortedIds, completion: { algoliaResult in
              switch algoliaResult {
              case .success(let hits):
                self.stories = hits
                self.state = .populated
              case .failure(let error):
                self.state = .error(error)
              }
            })
            self.state = .populated
        }
    }
  
    @objc func refreshHistory() {
      self.stories.removeAll()
      self.state = .loading
      
      if History.shared.items.isEmpty {
        self.state = .empty
      } else {
        self.AlgoliaClient.fetchStories(for: History.shared.sortedIds, completion: { algoliaResult in
          switch algoliaResult {
          case .success(let hits):
            self.stories = hits
            self.state = .populated
          case .failure(let error):
            self.state = .error(error)
          }
        })
        self.state = .populated
      }
    }
  
//    @objc func addHistoryRow(_ notification: Notification) {
//
//        guard let itemID = notification.userInfo?["visitedItemID"] as? String else { return }
//
//        // add the newly received "read" story to the history view data structure:
//        //storiesOfficialAPI.insert(item, at: 0)
//
//        // refresh the data source
//        //storiesDataSource.updateOfficialStories(with: storiesOfficialAPI)
//
//        // refresh the table view
//        //tableView.reloadData()
//
//        //tableView.beginUpdates()
//        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        //tableView.endUpdates()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! CommentsViewController
                let selectedItem = stories[indexPath.row]
                controller.algoliaStoryItem = selectedItem
                
                
                // change aspect of the opened story cell as now it's visited
                History.shared.add(id: selectedItem.objectID)
                if let parentType = parentType {
                    if parentType == .stories {
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    // Send the Parent Type for observing the proper Tab Bar notification
                    controller.parentType = parentType
                }
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func updateFooterView() {
        
        switch state {
            
        case .error(let error):
            errorLabel.text = error.localizedDescription
            tableView.tableFooterView = errorView
        case .loading:
            tableView.tableFooterView = loadingView
//      case .paging:
//          tableView.tableFooterView = loadingView
        case .empty:
            tableView.tableFooterView = emptyView
        case .populated:
            tableView.tableFooterView = UIView(frame: .zero)
        }
        
    }
}

extension StoriesChildViewController: StoriesDataSourceDelegate {
    func didUpdateState(_ newState: State) {
        self.state = newState
    }
    
    func didUpdateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
