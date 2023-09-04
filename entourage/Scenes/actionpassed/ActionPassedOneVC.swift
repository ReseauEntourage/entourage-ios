//
//  ActionPassedOneVC.swift
//  entourage
//
//  Created by Clement entourage on 19/07/2023.
//

import Foundation

protocol ActionPassedOneVCDelegate{
    func onDemandClick()
}

class ActionPassedOneVC:UIViewController {
    
    //OUTLET
    @IBOutlet weak var ui_label: UILabel!
    @IBOutlet weak var ic_cross: UIImageView!
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
            if self.actionId != 0 {
                ActionsService.cancelAction(isContrib: self.checkIfIsContrib(actType: self.actionType), actionId: self.actionId, isClosedOk: true, message: "") { action, error in
                }
            }
        }
    }
    
    func checkIfIsContrib(actType:String)->Bool{
        if self.actionType != nil && self.actionType == "contribution"{
            return true
        }else{
            return false
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
            AnalyticsLoggerManager.logEvent(name: Clic__StateContribPop__Yes__Day10)
            AnalyticsLoggerManager.logEvent(name: View__DeleteContribPop__Day10)

            self.ui_label.text = "custom_dialog_action_content_three_contrib".localized

        }else if actionType == "solicitation" {
            AnalyticsLoggerManager.logEvent(name: Clic__StateDemandPop__Yes__Day10)
            AnalyticsLoggerManager.logEvent(name: View__DeleteDemandPop__Day10)
            self.ui_label.text = "custom_dialog_action_content_three_demande".localized

        }
    }

}
