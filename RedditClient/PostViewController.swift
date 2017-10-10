//
//  ViewController.swift
//  RedditClient
//
//  Created by Rich Kolasa on 10/27/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//
import UIKit
import SafariServices

class PostViewController: UITableViewController, SFSafariViewControllerDelegate {
        
    var sourceID: String?
    var name: String? = "Time"
    var posts = [Post]()
    var safariVC: SFSafariViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /// Register the VC for 3D touch peek & pop
        registerForPreviewing(with: self, sourceView: view)
        
        /// refreshControl instance
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.refreshControl = refreshControl

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        name = UserDefaults.standard.object(forKey: "sourceName") as? String
        title = name
        
        sourceID = UserDefaults.standard.object(forKey: "sourceID") as? String
        getPosts(fromService: PostService())
        
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        getPosts(fromService: PostService())
        refreshControl.endRefreshing()
    }
    
    /// Clear posts array, add new posts from API
    func getPosts<Service: Gettable>(fromService service: Service) {
        service.get(sourceID: sourceID ?? "time", finished: { posts in
            self.posts = []
            self.posts += posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func unwindToPosts(segue: UIStoryboardSegue) {
    }
}

//Table View
extension PostViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        cell.title.text = post.title
        cell.number.text = "\(indexPath.row + 1)"
        cell.number.textColor = UIColor.randomColor()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        guard let urlString = post.url, let url = URL(string: urlString) else {
            return
        }
        
        // TODO: Replace with recommended code
        let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        
        if #available(iOS 10.0, *) {
            safariVC.preferredBarTintColor = .white
        } else {
            return
        }
        
        self.safariVC = safariVC
        present(safariVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/// 3D Touch Previewing
extension PostViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        /// Convert the 3D touch location to a more specific location in the table view
        if let indexPath = tableView.indexPathForRow(at: self.view.convert(location, to: self.tableView)) {
            
                previewingContext.sourceRect = tableView.rectForRow(at: (indexPath))
            
                /// The post at the touched location
                let post = posts[indexPath.row]
                
                guard let urlString = post.url, let url = URL(string: urlString) else {
                    print("Could not obtain post URL")
                    return self
                }
                
                let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                
                if #available(iOS 10.0, *) {
                    safariVC.preferredControlTintColor = .darkGray
                }
                
                self.safariVC = safariVC
                return safariVC
            }
        
        return nil
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
