//
//  MasterViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 5/25/18.
//  Copyright © 2018 Mihai Leonte. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit

enum State {
    case loadingCatalogue
    case loadingItems([Item])
    case populated([Item])
    case empty
    case error(Error)
    
    var currentItems: [Item] {
        switch self {
        case .loadingItems(let items):
            return items
        case .populated(let items):
            return items
        default:
            return []
        }
    }
}

class MasterViewController: UITableViewController {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    
    var detailViewController: DetailViewController? = nil
    let darkGreen = UIColor(red: 11/255, green: 86/255, blue: 14/255, alpha: 1)
    
    var state = State.loadingCatalogue {
        didSet {
            setFooterView()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.color = darkGreen
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
        let topStoriesURL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        fetchStoryIDs(from: topStoriesURL)
        state = State.loadingCatalogue
    }
    
    func fetchStoryIDs(from url: URL) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    // TODO: Handle error (call function) - client
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
                        
                        self.update(withIDs: stories)
                        
                    } catch let error {
                        print(error)
                        // TODO: Handle error (parse Json)
                    }
                }
                
            }
        }
        task.resume()
    }
    
    func update(withIDs:[Int]) {
        var allItems = self.state.currentItems
        for id in withIDs {
            allItems.append(Item(id: id))
        }
        
        self.state = State.loadingItems(allItems)
        self.fetchItems()
    }
    
    func fetchItems() {
        //self.state = State.loadingItems()
        print("fetched")
        print(state.currentItems[0])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - View Configuration
    
    func setFooterView() {
        switch state {
        case .error(let error):
            errorLabel.text = error.localizedDescription
            tableView.tableFooterView = errorView
        case .loadingCatalogue:
            tableView.tableFooterView = loadingView
        case .loadingItems:
            tableView.tableFooterView = nil
        case .empty:
            tableView.tableFooterView = emptyView
        case .populated:
            tableView.tableFooterView = nil
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let selectedItem = fetchedStories[indexPath.row]
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = selectedItem
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
    }
    

    
    // MARK - Data Source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedStories.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
//        let item = fetchedStories[indexPath.row]
//
//        if cell.accessoryView == nil {
//            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//            cell.accessoryView = indicator
//        }
//        let indicator = cell.accessoryView as! UIActivityIndicatorView
//
//        if let itemTitle = item.title {
//            cell.titleLabel?.text = itemTitle
//        } else {
//            cell.titleLabel?.text = "Loading..."
//        }
//
//        if let itemURL = item.url?.host {
//            cell.urlLabel?.text = itemURL
//        } else {
//            cell.urlLabel?.text = "Loading..."
//        }
//
//
//        if let itemDescendants = item.descendants {
//            cell.commentsCountLabel?.text = String(itemDescendants)
//        } else {
//            cell.commentsCountLabel?.text = "-"
//        }
//
//        if let itemScore = item.score {
//            cell.upvotesCountLabel?.text = String(itemScore)
//        } else {
//            cell.upvotesCountLabel?.text = "-"
//        }
//
//        if let epochTime = item.time {
//            // Display elapsed time
//            let componentsFormatter = DateComponentsFormatter()
//            componentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
//            componentsFormatter.maximumUnitCount = 1
//            componentsFormatter.unitsStyle = .abbreviated
//
//            let timeAgo = componentsFormatter.string(from: epochTime, to: Date())
//            cell.elapsedTimeLabel?.text = timeAgo
//        } else {
//            cell.elapsedTimeLabel?.text = "-"
//        }
//
//        switch (item.state) {
//        case .downloaded:
//            indicator.stopAnimating()
//        case .failed:
//            indicator.stopAnimating()
//            cell.titleLabel?.text = "Failed to load"
//        case .downloading:
//            cell.titleLabel?.text = "Download in progress..."
//        case .new:
//            indicator.startAnimating()
//            //if !tableView.isDragging && !tableView.isDecelerating
//            startDownload(for: item, at: indexPath)
//        }
//
//
//        return cell
//    }
    
//    func startDownload(for item: Item, at indexPath: IndexPath) {
//        //check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore this request.
//        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
//            return
//        }
//        
//        //create an instance of ItemDownloader by using the designated initializer.
//        let downloader = ItemDownloader(item)
//        
//        downloader.completionBlock = {
//            if downloader.isCancelled {
//                return
//            }
//            
//            // this will be executed instantly - before the response comes back, so the final reload will not be made
//            DispatchQueue.main.async {
//                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
//                self.tableView.reloadRows(at: [indexPath], with: .fade)
//            }
//        }
//        
//        pendingOperations.downloadsInProgress[indexPath] = downloader
//        pendingOperations.downloadQueue.addOperation(downloader)
//    }

}
