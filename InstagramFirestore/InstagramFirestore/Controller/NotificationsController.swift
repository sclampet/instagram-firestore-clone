//
// Created by Scott Clampett on 4/19/21.
//

import UIKit


private let cellId = "cellId"
class NotificationsController: UITableViewController {
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let refersher = UIRefreshControl()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        fetchNotications()
        configureRefresher()
    }
    
    //MARK: - Helpers
    
    func configureTableView() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    func configureRefresher() {
        refersher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refersher
    }
    
    //MARK: - API
    
    func fetchNotications() {
        NotificationService.fetchNotifications { (notifications) in
            self.notifications = notifications
            self.checkIfUserIsFollowed()
        }
    }
    
    func checkIfUserIsFollowed() {
        notifications.forEach { (notification) in
            guard notification.type == .follow else { return }
            
            UserService.checkIfUserIsFollowed(uid: notification.ownerUid) { (isFollowed) in
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].userIsFollowed = isFollowed
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotications()
        refersher.endRefreshing()
    }
}

//MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//MARK: - UITableViewDelegate

extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        
        UserService.fetchUser(withUid: notifications[indexPath.row].ownerUid) { (user) in
            self.showLoader(false)
            
            let controller = ProfileController(user: user, shouldHideTabBar: true)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//MARK: - INotificationCellDelegate

extension NotificationsController: INotificationCellDelegate {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        showLoader(true)
        
        UserService.follow(uid: uid) { (error) in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: error following user from notification follow button \(error.localizedDescription)")
            }
            
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        showLoader(true)
        
        UserService.unfollow(uid: uid) { (error) in
            self.showLoader(false)
            
            if let error = error {
                print("DEBUG: error unfollowing user from notification unfollow button \(error.localizedDescription)")
            }
            
            cell.viewModel?.notification.userIsFollowed.toggle()
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        showLoader(true)
        
        PostService.fetchPost(withPostId: postId) { (post) in
            self.showLoader(false)
            
            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.post = post
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
