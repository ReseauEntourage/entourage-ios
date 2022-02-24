//
//  OTMyEntourageMainViewController.swift
//  entourage
//
//  Created by Jerome on 10/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTMyEntourageMainViewController: UIViewController {
    
    @IBOutlet weak var ui_label_count_group: UILabel!
    @IBOutlet weak var ui_view_bubble_group: UIView!
    @IBOutlet weak var ui_label_count_private: UILabel!
    @IBOutlet weak var ui_view_bubble_private: UIView!
    @IBOutlet weak var ui_view_selector_group: UIView!
    @IBOutlet weak var ui_view_selector_messages: UIView!
    @IBOutlet weak var ui_label_bt_messages: UILabel!
    @IBOutlet weak var ui_label_bt_group: UILabel!
    @IBOutlet weak var ui_view_container: UIView!
    
    var groupsVC:UIViewController? = nil
    var messagesVC:UIViewController? = nil
    
    var tabSelectedIndex = -1
    
    var isAlreadyInitialized = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVCs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isAlreadyInitialized {
            changeButtons(newposition: 0)
            isAlreadyInitialized = true
        }
        loadCounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func loadCounts() {
        ui_view_bubble_group.isHidden = true
        ui_view_bubble_private.isHidden = true
        OTMessagesService.getMessagesMetadatas(withParams: nil) { metadatas, error in
            if let metadatas = metadatas {
                if let conv_unread = metadatas.conversations.unread, conv_unread > 0 {
                    self.ui_view_bubble_private.isHidden = false
                    self.ui_label_count_private.text = "\(conv_unread)"
                }
                
                if let actions_unread = metadatas.actions.unread, let outings_unread  = metadatas.outings.unread, actions_unread + outings_unread > 0 {
                    self.ui_view_bubble_group.isHidden = false
                    self.ui_label_count_group.text = "\(actions_unread + outings_unread)"
                }
            }
        }
    }
    
    func setupVCs() {
        groupsVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "MyEntourageMessages") as? OTMyEntourageMessagesViewController
        
        messagesVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "MyEntourageMessages") as? OTMyEntourageMessagesViewController
        (messagesVC as? OTMyEntourageMessagesViewController)?.isMessagesGroup = false
    }
    
    func changeVC() {
        if tabSelectedIndex == 1 {
            if let _ = groupsVC {
                groupsVC?.willMove(toParent: nil)
                groupsVC?.view.removeFromSuperview()
                groupsVC?.removeFromParent()
            }
            
            if let _ = messagesVC {
                addChild(messagesVC!)
                (messagesVC as? OTMyEntourageMessagesViewController)?.loadDatas()
                messagesVC?.view.frame.size = self.ui_view_container.frame.size
                ui_view_container.addSubview(messagesVC!.view)
                messagesVC!.didMove(toParent: self)
            }
        }
        else {
            if let _ = messagesVC {
                messagesVC?.willMove(toParent: nil)
                messagesVC?.view.removeFromSuperview()
                messagesVC?.removeFromParent()
            }
            
            if let _ = groupsVC {
                addChild(groupsVC!)
                (groupsVC as? OTMyEntourageMessagesViewController)?.loadDatas()
                groupsVC?.view.frame.size = self.ui_view_container.frame.size
                ui_view_container.addSubview(groupsVC!.view)
                groupsVC!.didMove(toParent: self)
            }
        }
    }
    
    func changeButtons(newposition:Int) {
        if newposition != tabSelectedIndex {
            tabSelectedIndex = newposition
            if newposition == 0 {
                ui_label_bt_group.textColor = UIColor.appOrange()
                ui_label_bt_messages.textColor = UIColor.appBlack30
                ui_view_selector_group.isHidden = false
                ui_view_selector_messages.isHidden = true
            }
            else {
                ui_label_bt_group.textColor = UIColor.appBlack30
                ui_label_bt_messages.textColor = UIColor.appOrange()
                ui_view_selector_group.isHidden = true
                ui_view_selector_messages.isHidden = false
            }
            changeVC()
        }
    }
    
    func setupVcsAfterTapTabbar() {
        if tabSelectedIndex == 0 {
            (groupsVC as? OTMyEntourageMessagesViewController)?.loadDatas()
        }
        else {
            (messagesVC as? OTMyEntourageMessagesViewController)?.loadDatas()
        }
    }
    
    @IBAction func action_select_group(_ sender: Any) {
        changeButtons(newposition: 0)
    }
    
    @IBAction func action_select_messages(_ sender: Any) {
        changeButtons(newposition: 1)
    }
}
