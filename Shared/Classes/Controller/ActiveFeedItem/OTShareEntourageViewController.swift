//
//  OTShareEntourageViewController.swift
//  entourage
//
//  Created by Jr on 07/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTShareEntourageViewController: UIViewController {
    
    @objc var feedItem:OTFeedItem? = nil
    @objc weak var delegate:InviteSuccessDelegate? = nil
    
    @IBOutlet weak var ui_bt_validate: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var selectedIndex = -1
    var arraySharings = [SharingEntourage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.tableFooterView = UIView(frame: CGRect.zero)
        
        updateButtonValidate()
        
        getSharings()
    }
    
    func updateButtonValidate() {
        var isSelected = false
        
        for share in arraySharings {
            if share.isSelected {
                isSelected = true
                break
            }
        }
        ui_bt_validate.isEnabled = isSelected
    }
    
    func getSharings() {
        OTShareEntourageService.getAllShareEntourage { (response) in
            if let _response = response {
                self.parseSharings(data: _response)
            }
        }
    }
    
    func parseSharings(data:[String:Any]) {
        if let sharings = data["sharing"] as? [[String:Any]] {
            for share in sharings {
                let _share = SharingEntourage.parse(data: share)
                if _share.uuid != feedItem!.uuid {
                    self.arraySharings.append(_share)
                }
            }
            self.ui_tableview.reloadData()
        }
    }
    
    
    @IBAction func action_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_validate(_ sender: Any) {
        SVProgressHUD.show()
        
        OTShareEntourageService.postAddShare(entourageId: arraySharings[selectedIndex].uuid, uuid: feedItem!.uuid) { (isOk) in
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                SVProgressHUD.showSuccess(withStatus: OTLocalisationService.getLocalizedValue(forKey: "sendShare"))
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - uitableview Datasource / delegate -
extension OTShareEntourageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySharings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OTSharingEntourageTableViewCell
        
        let share = arraySharings[indexPath.row]
        var type:String? = nil
        var imageUrl:String? = nil
        
        if let _display = share.category {
            type = share.entourageType + "_\(_display)"
        }
        else if share.groupType == "outing" {
            type = "ask_for_help_event"
        }
        else if share.groupType == "conversation" {
            type = nil
            imageUrl = share.avatarUrl
        }
        
        cell.populateCell(title: share.title, imageUrl: imageUrl, type: type, isSelected: share.isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in arraySharings.indices {
            if i == indexPath.row {
                self.selectedIndex = i
                arraySharings[i].isSelected = !arraySharings[i].isSelected
            }
            else {
                arraySharings[i].isSelected = false
            }
        }
        tableView.reloadData()
        updateButtonValidate()
    }
}

//MARK: - Sharing Entourage Model -
struct SharingEntourage {
    var id = 0
    var uuid = ""
    var title = ""
    var groupType = ""
    var entourageType = ""
    var category:String? = ""
    var avatarUrl:String? = nil
    
    var isSelected = false
    
    static func parse(data:[String:Any]) -> SharingEntourage {
        var share = SharingEntourage()
        share.id = data["id"] as! Int
        share.uuid = data["uuid"] as! String
        share.title = data["title"] as! String
        share.groupType = data["group_type"] as! String
        share.entourageType = data["entourage_type"] as! String
        share.category = data["display_category"] as? String
        
        if let _auth = data["author"] as? [String:Any] {
            share.avatarUrl = _auth["avatar_url"] as? String
        }
        
        return share
    }
}
