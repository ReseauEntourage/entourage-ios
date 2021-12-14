//
//  OTMyEntourageMainViewController.swift
//  entourage
//
//  Created by Jerome on 10/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTMyEntourageMainViewController: UIViewController {

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
    
    func setupVCs() {
        groupsVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "OTMyEntouragesViewController") as? OTMyEntouragesViewController
        messagesVC = UIStoryboard.myEntourages()?.instantiateViewController(withIdentifier: "MyEntourageMessages") as? OTMyEntourageMessagesViewController
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
                groupsVC?.view.frame.size = self.ui_view_container.frame.size
                ui_view_container.addSubview(groupsVC!.view)
                (messagesVC as? OTMyEntouragesViewController)?.isMessagesOnly = false
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

    
    @IBAction func action_select_group(_ sender: Any) {
        changeButtons(newposition: 0)
    }
    
    @IBAction func action_select_messages(_ sender: Any) {
        changeButtons(newposition: 1)
    }
    
    
}
