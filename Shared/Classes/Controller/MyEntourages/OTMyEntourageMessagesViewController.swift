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
    let LIMIT_PAGING = 20
    var currentPage = 1
    
    var firstLoading = true
    
    @IBOutlet weak var ui_tableView: UITableView!
    
    var arrayITems = [OTFeedItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoading {
            firstLoading = false
           loadDatas()
        }
    }
    
    func loadDatas() {
        self.arrayITems.removeAll()
        self.ui_tableView.reloadData()
        
        self.currentPage = 1
        requestData { items, error in
            if let _ = error  {
                self.arrayITems.removeAll()
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.ui_tableView.reloadData()
                }
            }
            else {
                if let items = items as? [OTFeedItem] {
                    DispatchQueue.main.async {
                        self.arrayITems.removeAll()
                        self.ui_tableView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        SVProgressHUD.dismiss()
                        self.arrayITems.append(contentsOf: items)
                        self.ui_tableView.reloadData()
                    }
                }
            }
        }
    }

    func requestData(completion: @escaping (Any?, Error?) -> Void) {
        SVProgressHUD.show()
        //Status -> all / active
        let params:[String:Any] = ["per":LIMIT_PAGING,"entourage_types":"ask_for_help,contribution","status":"active","unread_only":"false","page":currentPage]
        
        OTFeedsService().getMyFeeds(withParameters: params) { items in
            completion(items,nil)
        } failure: { error in
            completion(nil,error)
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
                          //  self.ui_tableView.beginUpdates()
                            self.arrayITems.append(contentsOf: items)
                            self.ui_tableView.reloadData()
                         //   self.ui_tableView.endUpdates()
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
        return arrayITems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = arrayITems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntourageCell", for: indexPath) as! OTEntourageMessageCell
        
        cell.configureWith(feedItem: item)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let feedItem = arrayITems[indexPath.row]
        
        let sb = UIStoryboard.init(name: "ActiveFeedItem", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! OTActiveFeedItemViewController
        vc.feedItem = feedItem
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
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
            //Load next page
            loadNextPage()
        }
    }
}



