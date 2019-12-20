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
            
            guard currentSelectedSourceAPI != nil else { return }
            
            print("OUTPUT storiesDataSource.update with parentType = \(parentType) and \(stories.count) stories")
            print("OUTPUT story title \(stories.first?.title)")
            print("OUTPUT self.tableView.frame.size \(self.tableView.frame.size)")
            print("OUTPUT self.tableView.frame.size \(self.tableView.frame.size)")
            
            
            storiesDataSource.update(
                algoliaStories: stories,
                parentType: parentType
            )
            tableView.reloadData()
            
//            if currentPage <= 1 {
//                //tableView.reloadAndScrollToFirstRow()
//                tableView.reloadData()
//            } else {
//                tableView.reloadData()
//            }
        }
    }
    
    var defaultSession: URLSession = URLSession(configuration: .default)
    var currentSelectedSourceAPI: HNFeedType?
    var currentSelectedFeedURL: URLComponents?
    var currentSelectedFeedID: Int8?
    var stories: [Story] = []
    var currentPage  = 0
    var isFetchInProgress = false
    
    // Stories, Bookmarks or History?
    var parentType: ParentStoriesChildViewController? 
    let AlgoliaClient = AlgoliaAPIClient()
    let OfficialClient = HNOfficialAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("OUTPUT: parentType = \(parentType)")
        
//        if (self.parent as? StoriesViewController) != nil {
//            parentType = .stories
//        } else if (self.parent as? BookmarksViewController) != nil {
//            parentType = .bookmarks
//        } else if (self.parent as? HistoryViewController) != nil {
//            parentType = .history
//        }
        
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        activityIndicator.color = UIColor.lightGray
        setUpPullToRefresh()
        
        storiesDataSource.delegate = self
        tableView.dataSource = storiesDataSource
        tableView.delegate = storiesDataSource
        tableView.prefetchDataSource = self
        
        
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
    
    // Initiate updating the Stories TableView based on the currently selected Feed (title, feedType/currentSourceAPI and feedURL)
    @objc func fetchStories() {
        
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        guard let currentSelectedSourceAPI = currentSelectedSourceAPI else { return }
        guard let currentSelectedFeedURL = currentSelectedFeedURL else { return }
        
        self.state = .loading
        
        switch currentSelectedSourceAPI {
            
        case .official:
            
            self.OfficialClient.fetchOfficialApiStoryIds(from: currentSelectedFeedURL) { officialStoriesResult in
                self.isFetchInProgress = false
                
                switch officialStoriesResult {
                case .success(let officialStories):
                    
                    self.AlgoliaClient.fetchStories(for: officialStories, completion: { algoliaResult in
                        switch algoliaResult {
                        case .success(let hits):
                            self.stories = self.filterSeenAndRead(stories: hits)
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
            self.AlgoliaClient.fetchStories(from: currentSelectedFeedURL, page: currentPage) { algoliaResult in
                self.isFetchInProgress = false
                
                switch algoliaResult {
                case .success(let hits):
                    self.currentPage += 1
                    print("OUTPUT self.currentPage \(self.currentPage)")
                    
                    self.stories.append(contentsOf: self.filterSeenAndRead(stories: hits))
                    self.state = .populated
                case .failure(let error):
                    self.state = .error(error)
                }
            }
        }
        
    }
    
    func filterSeenAndRead(stories: [Story]) -> [Story] {
        if Defaults.shared.hideSeen || Defaults.shared.hideRead {
            
            // History is already a Set but hits is an array of stories [Story]
            var storiesSet: Set<UInt32> = []
            for story in stories {
                let newID = UInt32(story.objectID) ?? 0
                storiesSet.insert(newID)
            }
            
            var filteredStoriesSet: Set<UInt32> = []
            
            if Defaults.shared.hideSeen {
                var seenSet: Set<UInt32> = []
                for item in History.shared.seenItems {
                    let newID = UInt32(item.id) ?? 0
                    seenSet.insert(newID)
                }
                
                filteredStoriesSet = storiesSet.subtracting(seenSet)
            }
            
            if Defaults.shared.hideRead {
                var readSet: Set<UInt32> = []
                for item in History.shared.readItems {
                    let newID = UInt32(item.id) ?? 0
                    readSet.insert(newID)
                }
                
                
                if Defaults.shared.hideSeen {
                    filteredStoriesSet = filteredStoriesSet.subtracting(readSet)
                } else {
                    filteredStoriesSet = storiesSet.subtracting(readSet)
                }
            }
            
            
            return stories.filter { filteredStoriesSet.contains(UInt32($0.objectID) ?? 0) }
        } else {
            return stories
        }
    }
    
    // Sets up Pull To Refresh - and calls refreshData()
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
        
        print("OUTPUT refreshData(): parentType = \(self.parentType)")
        
        guard let sourceParent = self.parentType else {
            sender.endRefreshing()
            return
        }
        
        switch sourceParent {
        case .stories:
            // refresh Feed URL
            currentSelectedFeedURL = Feeds.shared.selectedFeedURLComponents
            
            stories.removeAll()
            currentPage = 0
            fetchStories()
        case .bookmarks:
            refreshBookmarks()
        case .history:
            refreshHistory()
        }
        
        sender.endRefreshing()
    }
    
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
            //self.state = .populated
        }
    }
    
    @objc func refreshHistory() {
        self.stories.removeAll()
        self.state = .loading
        
        if History.shared.readItems.isEmpty {
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
            
            //self.state = .populated
        }
    }

    
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
                History.shared.add(id: selectedItem.objectID, withState: .read)
                
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

extension StoriesChildViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= stories.count
    }
}

extension StoriesChildViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            guard let currentSelectedSourceAPI = currentSelectedSourceAPI else { return }
            if currentSelectedSourceAPI == .algolia {
                
                let ac = UIAlertController(title: "Fetching new page", message: "Fetching page \(currentPage)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true)
                
                
                self.fetchStories()
            }
        }
        
    }
}
