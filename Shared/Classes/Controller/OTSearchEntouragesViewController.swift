//
//  OTSearchEntouragesViewController.swift
//  Pods
//
//  Created by Jerome on 20/09/2021.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager

class OTSearchEntouragesViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_tf_search: UITextField!
    @IBOutlet weak var ui_iv_clear: UIImageView!
    
    let minChars = 3
    
    var isAllreadyCall = false
    
    var isFromSearch = false
    
    var items = [OTFeedItem]()
    
    @objc var searchType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ui_iv_clear.isHidden = true
        ui_tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        ui_tf_search.becomeFirstResponder()
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        
        OTLogger.logEvent(Action_guide_searchStart)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showUserProfile), name: NSNotification.Name("showUserProfileFromFeed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    @objc func showUserProfile(notification: Notification) {
        if let userId = notification.object as? NSNumber {
            Logger.print("***** Show profile : --> number : \(userId)")
            
            let sb = UIStoryboard.init(name: "UserProfile", bundle: nil)
            if let navVc = sb.instantiateInitialViewController() as? UINavigationController {
                if let vc = navVc.topViewController as? OTUserViewController {
                    vc.userId = userId
                    self.present(navVc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func sendSearch(searchTxt:String) {
        if isAllreadyCall {
            return
        }
       
        isAllreadyCall = true
        
        SVProgressHUD.show()
        
        var types = ""
        if searchType == "outing" {
            types = "ou"
        }
        else if searchType == "ask" {
            types = "as,ae,am,ar,ai,ak,ao,ah"
        }
        else if searchType == "contrib" {
            types = "cs,ce,cm,cr,ci,ck,co,ch"
        }
        
        let newDict =  ["latitude":48.856614,
                        "longitude":2.3522219,
                        "q" : ui_tf_search.text!,
                        "types" : types] as [String : Any]
  
        OTFeedsService.init().getSearchEntourages(withParameters:newDict) { feeds, nextPageToken in
            Logger.print("***** return get feeds : \(feeds)")
            if let feeds = feeds as? [OTFeedItem] {
                self.items.removeAll()
                self.items.append(contentsOf: feeds)
                self.isFromSearch = true
                self.ui_tableview?.reloadData()
                self.isAllreadyCall = false
                SVProgressHUD.dismiss()
            }
        } failure: { error in
            Logger.print("***** return error get feeds : \(error?.localizedDescription)")
            self.items.removeAll()
            self.isFromSearch = false
            self.isAllreadyCall = false
            SVProgressHUD.dismiss()
            self.ui_tableview?.reloadData()
        }

    }
    
    //MARK: - IBActions
    @IBAction func action_clear(_ sender: Any) {
        if ui_tf_search.text?.count ?? 0 > 0 {
            ui_tf_search.text = ""
            self.items.removeAll()
            self.isFromSearch = false
            ui_tableview.reloadData()
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TableView Datasource/Delegate -
extension OTSearchEntouragesViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 && isFromSearch {
            return 1
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items.count == 0 && isFromSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty", for: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTNewsFeedTableViewCellIdentifier", for: indexPath) as! OTNewsFeedCell
        
      //  cell.configure(with: pois[indexPath.row])
        let item = items[indexPath.row]
        cell.configureLight(with: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items.count == 0 {
            return
        }
        
        
        let sb = UIStoryboard.init(name: "PublicFeedDetailNew", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? OTDetailActionEventViewController {
            vc.feedItem = items[indexPath.row]
            vc.isFromSearch = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Textfield Delegate -
extension OTSearchEntouragesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField.text?.count ?? 0 >= minChars {
            self.sendSearch(searchTxt: textField.text!)
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 0 {
            self.ui_iv_clear.isHidden = false
        }
        else {
            self.ui_iv_clear.isHidden = true
        }
    }
}
