//
//  FeedViewController.swift
//  BeReal-Clone
//
//  Created by Derrick Ng on 3/22/23.
//

import UIKit
import ParseSwift
import Alamofire

class FeedViewController: UIViewController {
    
    // connect the items in storyboard
    @IBOutlet weak var postPhotoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var request: Alamofire.Request?
    
    // create UIRefreshControl() Object
    let refreshControl = UIRefreshControl()
    
    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        // add Subview for refresh control
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts { success in
            if success {
                print("Data fetched successfully!")
            } else {
                print("Failed to fetch data...")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        request?.cancel() // Cancel the Alamofire request
    }
    
    @objc func refreshFeed() {
        // Cancel any previous request if it exists
        request?.cancel()
        
        // Fetch new data and update the UI here
        // For example, you can call a function that fetches the latest posts from a server
        queryPosts { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    // Reload the table view with the new data
                    self?.tableView.reloadData()
                }

                // Stop the refresh control
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    /// Query Posts
    // https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/2%20-%20Finding%20Objects.xcplaygroundpage/Contents.swift#L66
    private func queryPosts(completion: @escaping (Bool) -> Void) {
        
        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10) // <- Limit max number of returned posts to 10


        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
                // Call completion handler with success value
                completion(true)
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
                // Call completion handler with failure value
                completion(false)
            }
        }
    }
    
    @IBAction func onPostPhotoButtonTapped(_ sender: UIButton) {
        // Schedule a notification to remind the user to post again
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to post again!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let request = UNNotificationRequest(identifier: "postReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled")
            }
        }
    }
    
    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
    
    /// segue destination to the post details
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "pushSegue" {
//            if let postViewController = segue.destination as? PostViewController,
//                // Get the index path for the current selected table view row.
//               let selectedIndexPath = tableView.indexPathForSelectedRow {
//
//                // Get the task associated with the slected index path
//                let post = posts[selectedIndexPath.row]
//
//                // Set the selected task on the detail view controller.
//                postViewController.tappedPost = post
//            }
//        }
//    }
}

extension FeedViewController: UITableViewDelegate { }
