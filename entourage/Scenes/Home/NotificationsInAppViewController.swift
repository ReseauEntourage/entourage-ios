//
//  NotificationsInAppViewController.swift
//  entourage
//
//  Created by - on 22/11/2022.
//

import UIKit

class NotificationsInAppViewController: UIViewController {

    @IBOutlet weak var ic_notif_bell: UIImageView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var pullRefreshControl = UIRefreshControl()
    
    var notifications = [NotifInApp]()
    var currentPage = 1
    let numberOfItemsForWS = 25
    var isLoading = false
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call

    var hasToShowDot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "notifs_title".localized, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshDatas), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        self.ic_notif_bell.image = UIImage.init(named: "ic_notif_off")
        getNotifications()
        AnalyticsLoggerManager.logEvent(name: Home_view_notif)
        
        self.showOrNotBellOn()
    }
    
    @objc func refreshDatas() {
        currentPage = 1
        getNotifications()
    }
    
    func getNotifications() {
        if isLoading {return}
        
        isLoading = true
        
        HomeService.getNotifications(currentPage: currentPage, per: numberOfItemsForWS) { notifs, error in
            self.pullRefreshControl.endRefreshing()
            self.isLoading = false
            if let notifs = notifs {
                if self.currentPage == 1 {
                    self.notifications.removeAll()
                    self.notifications.append(contentsOf: notifs)
                    
                }
                else {
                    self.notifications.append(contentsOf: notifs)
                }
            }
            
            self.ui_tableview.reloadData()
        }
    }
    
    func showOrNotBellOn() {
        if hasToShowDot {
            self.ic_notif_bell.image = UIImage.init(named: "ic_notif_on")
            let timer = Timer(fireAt: Date().addingTimeInterval(2), interval: 0, target: self, selector: #selector(self.passBellOff), userInfo: nil, repeats: false)
                  
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    @objc func passBellOff() {
        hasToShowDot = false
        self.ic_notif_bell.image = UIImage.init(named: "ic_notif_off")
    }
}

//MARK: - Tableview Datasource/delegate -
extension NotificationsInAppViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let notif = self.notifications[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotifInAppCell
        if let _content = notif.content {
            cell.populateCell(title :"", content: _content, date: notif.getDurationFromNow(), imageUrl: notif.imageUrl, isUnread: notif.isRead(), instanceString: notif.getNotificationPushData().instanceType)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notif = self.notifications[indexPath.row]
        if notif.completedAt == nil {
            HomeService.markReadNotif(notifId: notif.uid) { notif, error in
                if let notif = notif {
                    self.notifications[indexPath.row].completedAt = notif.completedAt
                    self.ui_tableview.reloadData()
                }
            }
        }
        
        DeepLinkManager.presentAction(notification: notif.getNotificationPushData())
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        
        let lastIndex = notifications.count - nbOfItemsBeforePagingReload
        if indexPath.row == lastIndex  && self.notifications.count >= numberOfItemsForWS * currentPage {
            self.currentPage = self.currentPage + 1
            self.getNotifications()
        }
    }
}


//MARK: - MJNavBackViewDelegate -
extension NotificationsInAppViewController: MJNavBackViewDelegate {
    func goBack() {
        //  self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}

