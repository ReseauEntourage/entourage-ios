//
//  ActionMainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import IQKeyboardManagerSwift

class ActionsMainHomeViewController: UIViewController {

    @IBOutlet weak var ui_floaty_button: Floaty!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        setupFloatingButton()
        
        //Notif for updating when create new action
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreate), name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        
        //Notif for showing new created action
        NotificationCenter.default.addObserver(self, selector: #selector(showNewAction(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewAction), object: nil)
    }
    
    func setupFloatingButton() {
        let floatItem1 = createButtonItem(title: "action_menu_demand".localized, iconName: "ic_menu_button_create_event") { item in
            self.createAction(isContrib:false)
        }
        
        let floatItem2 = createButtonItem(title: "action_menu_contrib".localized, iconName: "ic_menu_button_create_post") { item in
            self.createAction(isContrib:true)
        }
        
        ui_floaty_button.overlayColor = .white.withAlphaComponent(0.10)
        ui_floaty_button.addBlurOverlay = true
        ui_floaty_button.itemSpace = 24
        ui_floaty_button.addItem(item: floatItem2)
        ui_floaty_button.addItem(item: floatItem1)
        ui_floaty_button.sticky = true
        ui_floaty_button.animationSpeed = 0.3
        ui_floaty_button.fabDelegate = self
    }

    func createAction(isContrib:Bool) {
        let sb = UIStoryboard.init(name: StoryboardName.actions, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "actionCreateVCMain") as? ActionCreateMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isContrib = isContrib
            vc.parentController = self
            self.tabBarController?.present(vc, animated: true)
        }
    }
    
    @objc func showNewAction(_ notification:Notification) {
        if let actionId = notification.userInfo?[kNotificationActionShowId] as? Int {
            Logger.print("***** Show new Action : \(actionId)")
            DispatchQueue.main.async {
               // self.showEvent(eventId: eventId, isAfterCreation: true)
            }
        }
    }
    
    @objc func updateFromCreate() {
        //TODO: - refresh lists after creating action
    }
    
}

//MARK: - FloatyDelegate -
extension ActionsMainHomeViewController:FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        
    }
    
    private func createButtonItem(title:String, iconName:String, handler:@escaping ((FloatyItem) -> Void)) -> FloatyItem {
        let floatyItem = FloatyItem()
        floatyItem.buttonColor = .clear
        floatyItem.icon = UIImage(named: iconName)
        floatyItem.titleLabel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        floatyItem.titleShadowColor = .clear
        floatyItem.title = title
        floatyItem.imageSize = CGSize(width: 62, height: 62)
        floatyItem.handler = handler
        return floatyItem
    }
}
