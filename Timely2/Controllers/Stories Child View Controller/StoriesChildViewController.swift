//
//  MasterViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

// This ChildViewController can be embedded in one of the following types of View Controllers
enum ParentStoriesChildViewController {
    case stories
    case bookmarks
    case history
}

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
            
            storiesDataSource.setData(
                sourceAPI: currentSelectedSourceAPI,
                stories: storiesOfficialAPI,
                algoliaStories: storiesAlgoliaAPI,
                parentType: parentType
            )
            tableView.reloadAndScrollToFirstRow()
        }
    }
    
    var defaultSession: URLSession = URLSession(configuration: .default)
    var currentSelectedSourceAPI: HNFeedType?
    var currentSelectedFeedURL: URLComponents? //= URLComponents(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
    
    var storiesAlgoliaAPI: [AlgoliaItem] = []
    var storiesOfficialAPI: [Item] = []
    

    // Stories, Bookmarks or History?
    var parentType: ParentStoriesChildViewController?
    
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
        

        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        self.defaultSession = URLSession(configuration: configuration)
        
        
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
        
        self.state = .loading
        
        switch currentSelectedSourceAPI {
            
        case .official:
            self.storiesOfficialAPI.removeAll()
            fetchOfficialApiStories(from: currentSelectedFeedURL)
        case .algolia:
            self.storiesAlgoliaAPI.removeAll()
            fetchAlgoliaApiStories(from: currentSelectedFeedURL)
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
        self.storiesOfficialAPI.removeAll()
        self.state = .loading
        
        if Bookmarks.shared.stories.isEmpty {
            self.state = .empty
        } else {
            self.storiesOfficialAPI = Bookmarks.shared.stories
            self.state = .populated
            self.fetchOfficialApiStoryItems()
        }
    }
    
    @objc func addHistoryRow(_ notification: Notification) {
        
        guard let itemID = notification.userInfo?["visitedItemID"] as? String else { return }
        
        // add the newly received "read" story to the history view data structure:
        //storiesOfficialAPI.insert(item, at: 0)
        
        // refresh the data source
        //storiesDataSource.updateOfficialStories(with: storiesOfficialAPI)
        
        // refresh the table view
        //tableView.reloadData()
        
        //tableView.beginUpdates()
        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        //tableView.endUpdates()
    }
    
    @objc func refreshHistory() {
        self.storiesOfficialAPI.removeAll()
        self.state = .loading
        
        if History.shared.stories.isEmpty {
            self.state = .empty
        } else {
            self.storiesOfficialAPI = History.shared.stories
            self.state = .populated
            self.fetchOfficialApiStoryItems()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func fetchAlgoliaApiStories(from urlComponents: URLComponents) {
        
        self.storiesOfficialAPI.removeAll()
        
        if let url = urlComponents.url {
        
            _ = self.defaultSession.dataTask(with: url) { responseData, response, error in
                
                    if let error = error {
                        self.state = .error(error)
                        return
                    }
                
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            // FIXME: add response status code
                            self.state = .error(HNError.network(""))
                            return
                    }
                
                    if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = responseData {
                        //print("JSON String: \(String(data: data, encoding: .utf8))")
                        
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .customISO8601
                            let stories = try decoder.decode(AlgoliaItemList.self, from: data)
                            
                            DispatchQueue.main.async {
                                self.storiesAlgoliaAPI = stories.hits
                                self.state = .populated
                            }
                        } catch let error {
                            self.state = .error(HNError.parsingJSON(error.localizedDescription))
                        }
                    }
            }.resume()
        }
    }
    
    // Official API
    func fetchOfficialApiStories(from urlComponents: URLComponents) {
        
        self.storiesAlgoliaAPI.removeAll()

        if let url = urlComponents.url {
        
            let task = self.defaultSession.dataTask(with: url) { data, response, error in
                // TODO - could this be moved only on the reload of the tableView?
                DispatchQueue.main.async {
                    if let error = error {
                        self.state = .error(error)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            self.state = .error(HNError.network(""))
                            return
                    }
                    
                    if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let stories = try decoder.decode([Int].self, from: data)
                            
                            for storyId in stories.prefix(20) {
                                self.storiesOfficialAPI.append(Item(id: storyId))
                            }
                            
                            self.state = .populated

                            self.fetchOfficialApiStoryItems()
                            
                            
                            
                        } catch let error {
                            self.state = .error(HNError.parsingJSON(error.localizedDescription))
                        }
                    }
                }
            }
            task.resume()
        }
    }

    // Official API
    func fetchOfficialApiStoryItems() {

        for (index, item) in self.storiesOfficialAPI.enumerated() {
            
            self.storiesOfficialAPI[index].state = .downloading
            
            // Construct the URLRequest
            let itemID = String(item.id)
            let urlString = "https://hacker-news.firebaseio.com/v0/item/\(itemID).json"
            let requestItem = URLRequest(url: URL(string: urlString)!)
            
            let taskItem = self.defaultSession.dataTask(with: requestItem) { data, response, error in
                
                if let data = data, let response = response as? HTTPURLResponse {
                    let statusCode = response.statusCode
                    if statusCode == 200 {
                        //print("200 OK on Item ID = \(itemID)")
                        
                        self.storiesOfficialAPI[index].state = .downloaded
                        //print(data)
                    
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .secondsSince1970
                            let story = try decoder.decode(Item.self, from: data)

                            guard story.deleted == nil else {
                                print("Deleted HN Item \(itemID) was ignored")
                                return
                            }
                            
                            guard story.type == .story else {
                                print("HN Item \(itemID) was ignored because it was not a story type.")
                                return
                            }
                            
                            self.storiesOfficialAPI[index].title = story.title
                            self.storiesOfficialAPI[index].url = story.url
                            self.storiesOfficialAPI[index].by = story.by
                            self.storiesOfficialAPI[index].descendants = story.descendants
                            self.storiesOfficialAPI[index].score = story.score
                            self.storiesOfficialAPI[index].time = story.time
                            self.storiesOfficialAPI[index].kids = story.kids

                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            }
                        }
                        catch let error {
                            print("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription)
                            print(error)
                            
                            self.storiesOfficialAPI[index].state = .failed
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            }
                        }
                    }
                }
                
            }
            taskItem.resume()
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
                
                guard let currentSelectedSourceAPI = currentSelectedSourceAPI else { return }
                
                switch currentSelectedSourceAPI {
                case .official:
                    let selectedItem = storiesOfficialAPI[indexPath.row]
                    controller.officialStoryItem = selectedItem
                    
                    History.shared.add(id: String(selectedItem.id))
                case .algolia:
                    let selectedItem = storiesAlgoliaAPI[indexPath.row]
                    controller.algoliaStoryItem = selectedItem
                    
                    History.shared.add(id: selectedItem.objectID)
                }
                
                
                if let parentType = parentType {
                    
                    if parentType == .stories {
                        // change aspect of the opened story cell as visited
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
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
