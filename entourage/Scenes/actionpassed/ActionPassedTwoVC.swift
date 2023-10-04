//
//  ActionPassedTwoVC.swift
//  entourage
//
//  Created by Clement entourage on 19/07/2023.
//

import Foundation

class ActionPassedTwoVC:UIViewController {
    
    //OUTLET
    @IBOutlet weak var ui_label: UILabel!
    @IBOutlet weak var ui_btn: UIButton!
    @IBOutlet weak var ic_cross: UILabel!
    var actionId = 0
    var actionType:String = ""
    
    //VARIABLE
    
    override func viewDidLoad() {
        ic_cross.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked(tapGestureRecognizer:)))
        ic_cross.addGestureRecognizer(tapGestureRecognizer)
        updateActionType(actionType: self.actionType)
        
    }
    
    @objc func onCrossClicked(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func onClickGoDemand(){
        self.dismiss(animated: true) {
            DeepLinkManager.showContribListUniversalLink()
        }
    }
    
    @objc func onClickGoContrib(){
        self.dismiss(animated: true) {
            DeepLinkManager.showSolicitationListUniversalLink()

        }
    }
    
    
    func setActionId(id:Int){
        self.actionId = id
    }
    
    func setActionType(actionType:String){
        self.actionType = actionType
    }
    
    func updateActionType(actionType:String){
        if actionType == "contribution" {
            AnalyticsLoggerManager.logEvent(name: Clic__StateContribPop__No__Day10)
            AnalyticsLoggerManager.logEvent(name: View__StateContribPop__No__Day10)

            self.ui_label.text = "custom_dialog_action_content_two_demande".localized
            self.ui_btn.setTitle("custom_dialog_action_two_button_demand".localized, for: .normal)
            self.ui_btn.addTarget(self, action: #selector(onClickGoContrib), for: .touchUpInside)

        }else if actionType == "solicitation" {
            AnalyticsLoggerManager.logEvent(name: Clic__StateDemandPop__No__Day10)
            AnalyticsLoggerManager.logEvent(name: View__StateDemandPop__No__Day10)

            self.ui_label.text = "custom_dialog_action_content_two_contrib".localized
            self.ui_btn.setTitle("custom_dialog_action_two_button_contrib".localized, for: .normal)
            self.ui_btn.addTarget(self, action: #selector(onClickGoDemand), for: .touchUpInside)

        }
    }
    
}
