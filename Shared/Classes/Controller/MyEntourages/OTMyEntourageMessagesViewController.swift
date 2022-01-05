//
//  OTMyEntourageMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 10/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTMyEntourageMessagesViewController: UIViewController {
    
    let LOAD_MORE_DRAG_OFFSET:CGFloat = 50
    let LIMIT_PAGING = 10
    var currentPage = 1
    
    var firstLoading = true
    
    var isMessagesGroup = true
    
    @IBOutlet weak var ui_view_no_data: UIView!
    @IBOutlet weak var ui_tableView: UITableView?
    
    var arrayItems = [OTFeedItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(loadDatas), for: .valueChanged)
        refreshControl.tintColor = UIColor.appOrange()
        
        if #available(iOS 10.0, *) {
            ui_tableView?.refreshControl = refreshControl
        } else {
            ui_tableView?.addSubview(refreshControl)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoading {
            firstLoading = false
            loadDatas()
        }
    }
    
    @objc func loadDatas() {
        self.arrayItems.removeAll()
        self.ui_tableView?.reloadData()
        
        self.currentPage = 1
        requestData { items, error in
            if let _ = error  {
                self.arrayItems.removeAll()
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.refreshControl.endRefreshing()
                    self.ui_tableView?.reloadData()
                    self.showEmptyView()
                }
            }
            else {
                if let items = items as? [OTFeedItem] {
                    DispatchQueue.main.async {
                        self.arrayItems.removeAll()
                        self.ui_tableView?.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        SVProgressHUD.dismiss()
                        self.refreshControl.endRefreshing()
                        self.arrayItems.removeAll()
                        self.arrayItems.append(contentsOf: items)
                        self.ui_tableView?.reloadData()
                        self.showEmptyView()
                    }
                }
            }
        }
    }
    
    func showEmptyView() {
        if arrayItems.count == 0 {
            ui_view_no_data.isHidden = false
        }
        else {
            ui_view_no_data.isHidden = true
        }
    }
    
    func requestData(completion: @escaping (Any?, Error?) -> Void) {
        SVProgressHUD.show()
        
        let params:[String:Any] = ["per":LIMIT_PAGING,"page":currentPage]
        
        if isMessagesGroup {
            OTMessagesService.getMessagesGroup(withParams: params) { items, error in
                completion(items,error)
            }
        }
        else {
            OTMessagesService.getMessagesOne2One(withParams: params) { items, error in
                completion(items,error)
            }
        }
    }
    
    func loadNextPage() {
        self.currentPage = self.currentPage + 1
        
        requestData { items, error in
            SVProgressHUD.dismiss()
            if let _ = error  {
                self.currentPage = self.currentPage - 1
            }
            else {
                if let items = items as? [OTFeedItem] {
                    if items.count == 0 && self.currentPage > 1 {
                        self.currentPage = self.currentPage - 1
                    }
                    else {
                        DispatchQueue.main.async {
                            self.arrayItems.append(contentsOf: items)
                            self.ui_tableView?.reloadData()
                        }
                    }
                }
            }
        }
    }
}

//MARK: - uitableview Datsource / delegate -
extension OTMyEntourageMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = arrayItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntourageCell", for: indexPath) as! OTEntourageMessageCell
        cell.configureWith(feedItem: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrayItems[indexPath.row].unreadMessageCount = 0
        let feedItem = arrayItems[indexPath.row]
        let sb = UIStoryboard.init(name: "ActiveFeedItem", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! OTActiveFeedItemViewController
        vc.feedItem = feedItem
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        if y > h + LOAD_MORE_DRAG_OFFSET {
            loadNextPage()
        }
    }
}



