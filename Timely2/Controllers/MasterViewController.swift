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

let HN_TOP_STORIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json"

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    var fetchedStories: [Item] = []

    let pendingOperations = PendingOperations()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        firstly {
            fetchTopStoryIDs()
        }.then {
            print("Promise ok. fetchedStories.count = ")
            print(self.fetchedStories.count)
        }.catch { error in
            print('Error')
        }
        //tableView.reloadData() //this might be needed if there's a bug with the Cell height initially...
    }


    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedItem = fetchedStories[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = selectedItem
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: Fetch Top Stories
    
    
    func fetchTopStoryIDs() -> Promise<[Item]> {
        let request = URLRequest(url: URL(string: HN_TOP_STORIES_URL)!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Promise { seal in
            URLSession(configuration: .default).dataTask(with: request) { data, response, error in
                
                let alertController = UIAlertController(title: "Oops!", message: "There was an error fetching HN stories.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                
                if let topStories = data {
                    //do {
                    for itemID in topStories.prefix(upTo: 3) { //
                        let newItem = Item(id: Int(itemID))
                        self.fetchedStories.append(newItem)
                    }
                    
                    seal.resolve(fetchedStories, error)
                }
            }.resume()
        }
    }
                    //self.dataSource.update(with: self.fetchedStories)
                    
//                    DispatchQueue.main.async {
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        self.tableView.reloadData()
//                        print("fetchTopStoryIDs() count = ")
//                        print(self.fetchedStories.count)
//                    }
                    //                } catch {
                    //                    DispatchQueue.main.async {
                    //                        self.present(alertController, animated: true, completion: nil)
                    //                    }
                    //                }
                
                
//                if error != nil {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//                }


    
    // MARK - Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedStories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
        let item = fetchedStories[indexPath.row]
        
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
            cell.urlLabel?.text = "Loading..."
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
        case .downloaded:
            indicator.stopAnimating()
        case .failed:
            indicator.stopAnimating()
            cell.titleLabel?.text = "Failed to load"
        case .downloading:
            cell.titleLabel?.text = "Download in progress..."
        case .new:
            indicator.startAnimating()
            //if !tableView.isDragging && !tableView.isDecelerating 
            startDownload(for: item, at: indexPath)
        }
        
        
        return cell
    }
    
    func startDownload(for item: Item, at indexPath: IndexPath) {
        //check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore this request.
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        //create an instance of ItemDownloader by using the designated initializer.
        let downloader = ItemDownloader(item)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            // this will be executed instantly - before the response comes back, so the final reload will not be made
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }

}
