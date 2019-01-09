//
//  MasterViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit

//enum sourceAPI {
//    case official
//    case algolia
//}

class MasterViewController: UITableViewController {
    
    var topStories: [Item] = []
    var algoliaStories: [AlgoliaItem] = []
    var currentSourceAPI: HNFeedType = .official
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var feedButton: UIBarButtonItem!
    @IBOutlet var feedPopoverView: UIView!
    @IBOutlet weak var cancelFeedButton: UIBarButtonItem!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var headerTitle: UINavigationItem!
    
    var detailViewController: DetailViewController? = nil
    let darkGreen = UIColor(red: 11/255, green: 86/255, blue: 14/255, alpha: 1)
    var myRefreshControl: UIRefreshControl?
    let topStoriesURL = URLComponents(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
    var blurEffectView: UIView = UIView()
    var feedDataSource: FeedDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myFeeds: [Feed] = loadFeedsFromFile()
        setFeedTableView(with: myFeeds)
        customizeFeedPopoverView()
        setUpPullToRefresh()
        
        activityIndicator.color = darkGreen
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
        self.headerTitle.title = "HN Top Stories"
        fetchStoryIDs(from: topStoriesURL)
        
    }
    
    /// Loads Feed data from FeedList.plist and parses it in an array of Feed type.
    ///
    /// - Returns: a Feed array
    func loadFeedsFromFile() -> [Feed] {
        var myFeeds: [Feed] = []
        if let feedListURL = Bundle.main.url(forResource: "FeedList", withExtension: "plist") {
            do {
                let feedListData = try Data(contentsOf: feedListURL)
                let plistDecoder = PropertyListDecoder()
                myFeeds = try plistDecoder.decode([Feed].self, from: feedListData)
            } catch {
                print(error)
            }
        }
        return myFeeds
    }
    
    /// Sets up a new TableView to select the Feed/Sort option.
    ///
    /// - Parameter feed: the [Feed] object - FeedList.plist parsed
    func setFeedTableView(with feed: [Feed]) {
        feedDataSource = FeedDataSource()
        feedDataSource.setData(feedList: feed)
        feedDataSource.cellDelegate = self
        self.feedTableView.dataSource = feedDataSource
        self.feedTableView.delegate = feedDataSource
        self.feedTableView.register(FeedCell.self, forCellReuseIdentifier: "TableViewCell")
    }
    
    /// Sets up the Popover View which contains the Feed/Sort TableView. And sets a Blur effect which will sit under.
    func customizeFeedPopoverView() {
        self.feedPopoverView.layer.cornerRadius = 8.0
        self.feedPopoverView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5
        self.cancelFeedButton.tintColor = .clear
    }
    
    /// Sets up Pull To Refresh - and calls refreshData()
    func setUpPullToRefresh() {
        myRefreshControl = UIRefreshControl()
        myRefreshControl?.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        myRefreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.tableView.refreshControl = myRefreshControl
    }
    
    @objc func refreshData(sender: UIRefreshControl) {
        print("refreshing data")
        
        fetchStoryIDs(from: topStoriesURL)
        
        sender.endRefreshing()
    }
    
    // feedButton pressed
    @IBAction func changeFeed(_ sender: Any) {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(feedPopoverView)
        feedPopoverView.translatesAutoresizingMaskIntoConstraints = false
        feedPopoverView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        feedPopoverView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        feedPopoverView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        feedPopoverView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        //Show the Cancel button
        self.cancelFeedButton.isEnabled = true
        self.cancelFeedButton.tintColor = nil
    }
    
    // When pressing Cancel Bar Button
    @IBAction func cancelFeedPopover(_ sender: Any) {
        closePopoverView()
    }
    
    func closePopoverView() {
        self.feedPopoverView.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
        self.cancelFeedButton.isEnabled = false
        self.cancelFeedButton.tintColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func fetchAlgoliaStories(from urlComponents: URLComponents) {
        
        self.topStories.removeAll()
        self.tableView.reloadData()
        
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let defaultSession = URLSession(configuration: configuration)

        
        if let url = urlComponents.url {
        
            let task = defaultSession.dataTask(with: url) { responseData, response, error in
                
                    if let error = error {
                        // TODO: Handle error (call function) - client side
                        print(error)
                        return
                    }
                
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            // TODO: Handle error (call function) - server side
                            return
                    }
                
                    if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = responseData {
                        print("JSON String: \(String(data: data, encoding: .utf8))")
                        
                        do {
                            let decoder = JSONDecoder()
                            
                            //decoder.dateDecodingStrategy = .iso8601(options: .withInternetDateTimeExtended)
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            decoder.dateDecodingStrategy = .formatted(dateFormatter)
                            
                            let stories = try decoder.decode(AlgoliaItemList.self, from: data)
                            //print(stories)
                            
                            DispatchQueue.main.async {
                                self.algoliaStories = stories.hits
                                self.tableView.reloadData()
                            }
                        } catch let error {
                            print(error)
                            // TODO: Handle error (parse Json)
                        }
                    }
            }.resume()
        }
    }
    
    // Official API
    func fetchStoryIDs(from urlComponents: URLComponents) {
        if let url = urlComponents.url {
        
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                // TODO - could this be moved only on the reload of the tableView?
                DispatchQueue.main.async {
                    if let error = error {
                        // TODO: Handle error (call function) - client side
                        print(error)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            // TODO: Handle error (call function) - server side
                            return
                    }
                    
                    if let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let stories = try decoder.decode([Int].self, from: data)
                            self.topStories.removeAll()
                            for storyId in stories.prefix(20) {
                                self.topStories.append(Item(id: storyId))
                            }
                            self.tableView.reloadData()
                            self.fetchItems()
                            
                        } catch let error {
                            print(error)
                            // TODO: Handle error (parse Json)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    // Official API
    func fetchItems() {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let defaultSession = URLSession(configuration: configuration)
        
        for (index, item) in self.topStories.enumerated() {
            
            self.topStories[index].state = .downloading
            
            // Construct the URLRequest
            let itemID = String(item.id)
            let urlString = "https://hacker-news.firebaseio.com/v0/item/\(itemID).json"
            let requestItem = URLRequest(url: URL(string: urlString)!)
            
            let taskItem = defaultSession.dataTask(with: requestItem) { data, response, error in
                
                if let data = data, let response = response as? HTTPURLResponse {
                    let statusCode = response.statusCode
                    if statusCode == 200 {
                        //print("200 OK on Item ID = \(itemID)")
                        self.topStories[index].state = .downloaded
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
                            
                            self.topStories[index].title = story.title
                            self.topStories[index].url = story.url
                            self.topStories[index].by = story.by
                            self.topStories[index].descendants = story.descendants
                            self.topStories[index].score = story.score
                            self.topStories[index].time = story.time
                            self.topStories[index].kids = story.kids
                            //print(story.kids)
                            DispatchQueue.main.async {
                                //reloadRows has an expected argument type of [IndexPath]
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            }
                        }
                        catch let error {
                            print("Could not convert JSON data into a dictionary. Error: " + error.localizedDescription)
                            print(error)
                            self.topStories[index].state = .failed
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
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                switch currentSourceAPI {
                case .official:
                    let selectedItem = topStories[indexPath.row]
                    controller.detailItem = selectedItem
                case .algolia, .timely:
                    let selectedItem = algoliaStories[indexPath.row]
                    controller.algoliaItem = selectedItem
                }
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    

    
    // MARK - Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.currentSourceAPI {
        case .official:
            return self.topStories.count
        case .algolia, .timely:
            return self.algoliaStories.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
        
        switch self.currentSourceAPI {
        case .official:
            let item = self.topStories[indexPath.row]
            
            if cell.accessoryView == nil {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                cell.accessoryView = indicator
            }
            let indicator = cell.accessoryView as! UIActivityIndicatorView
            
            if let itemTitle = item.title {
                cell.titleLabel?.text = itemTitle
            } else {
                cell.titleLabel?.text = "Loading..."
            }
            
            if let itemURL = item.url?.host {
                cell.urlLabel?.text = itemURL
            } else {
                cell.urlLabel?.text = "Story ID: " + String(item.id)
            }
            
            
            if let itemDescendants = item.descendants {
                cell.commentsCountLabel?.text = String(itemDescendants)
            } else {
                cell.commentsCountLabel?.text = "-"
            }
            
            if let itemScore = item.score {
                cell.upvotesCountLabel?.text = String(itemScore)
            } else {
                cell.upvotesCountLabel?.text = "-"
            }
            
            if let epochTime = item.time {
                // Display elapsed time
                let componentsFormatter = DateComponentsFormatter()
                componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                componentsFormatter.maximumUnitCount = 1
                componentsFormatter.unitsStyle = .abbreviated
                
                
                let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
                cell.elapsedTimeLabel?.text = timeAgo
            } else {
                cell.elapsedTimeLabel?.text = "-"
            }
            
            switch (item.state) {
            case .downloaded?:
                indicator.stopAnimating()
            case .failed?:
                indicator.stopAnimating()
                cell.titleLabel?.text = "Failed to load"
            case .downloading?:
                cell.titleLabel?.text = "Download in progress..."
            case .new?:
                indicator.startAnimating()
                //if !tableView.isDragging && !tableView.isDecelerating
            //startDownload(for: item, at: indexPath)
            case nil:
                print("Error nil state to be displayed")
            }
            
        case .algolia, .timely:
            let item = self.algoliaStories[indexPath.row]
            
            if let itemTitle = item.title {
                cell.titleLabel?.text = itemTitle
            } else {
                cell.titleLabel?.text = "Loading..."
            }

            if let itemURL = item.url?.host {
                cell.urlLabel?.text = itemURL
            } else {
                cell.urlLabel?.text = "Story ID: " + String(item.objectID)
            }


            if let itemDescendants = item.num_comments {
                cell.commentsCountLabel?.text = String(itemDescendants)
            } else {
                cell.commentsCountLabel?.text = "-"
            }

            if let itemScore = item.points {
                cell.upvotesCountLabel?.text = String(itemScore)
            } else {
                cell.upvotesCountLabel?.text = "-"
            }

            //if let epochTime = item.created_at {
            // Display elapsed time
            let componentsFormatter = DateComponentsFormatter()
            componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
            componentsFormatter.maximumUnitCount = 1
            componentsFormatter.unitsStyle = .abbreviated
            let timeAgo = componentsFormatter.string(from: item.created_at, to: Date())
            cell.elapsedTimeLabel?.text = timeAgo
//            } else {
//                cell.elapsedTimeLabel?.text = "-"
//            }
            
        }

        return cell
    }
}

extension MasterViewController: CellFeedProtocol {
    func didTapCell(feedURL: URLComponents, title: String, type: HNFeedType) {
        closePopoverView()
        
        self.headerTitle.title = title
        self.currentSourceAPI = type
        
        switch type {
        case .official:
            fetchStoryIDs(from: feedURL)
        case .timely:
            fetchStoryIDs(from: feedURL)
        case .algolia:
            fetchAlgoliaStories(from: feedURL)
        }
    }
    
}
