//
//  ViewController.swift
//  RedditClient
//
//  Created by Rich Kolasa on 10/27/16.
//  Copyright © 2016 Rich Kolasa. All rights reserved.
//
import UIKit
import SafariServices


class PostViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSourcesButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var sourceID: String?
    var name: String? = "Time"
    var posts = [Post]()
    var safariVC: SFSafariViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        registerForPreviewing(with: self, sourceView: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        name = UserDefaults.standard.object(forKey: "sourceName") as? String
        sourceID = UserDefaults.standard.object(forKey: "sourceID") as? String
        title = name
        
        getPosts(fromService: PostService())
    }
    
    func setUpUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        self.automaticallyAdjustsScrollViewInsets = false

        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = #colorLiteral(red: 0.8687419987, green: 0.3399184699, blue: 0.2972750098, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getPosts(fromService: PostService())
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getPosts<Service: Gettable>(fromService service: Service) {
        service.get(sourceID: sourceID ?? "time", finished: { posts in
            self.posts = []
            self.posts += posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func unwindToPosts(segue: UIStoryboardSegue) {}
}

//Table View
extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        cell.title.text = post.title
        cell.number.text = "\(indexPath.row + 1)"
        cell.number.textColor = UIColor.randomColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
            guard let urlString = post.url, let url = URL(string: urlString)  else {
                return
            }
            
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

//3D Touch Previewing
extension PostViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            
            print(indexPath)
            previewingContext.sourceRect = tableView.rectForRow(at: (indexPath))
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
