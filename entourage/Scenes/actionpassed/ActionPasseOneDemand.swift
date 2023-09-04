//
//  ActionPasseOneDemand.swift
//  entourage
//
//  Created by Clement entourage on 01/09/2023.
//

import Foundation
import UIKit


class ActionPasseOneDemand:UIViewController {
    
    @IBOutlet weak var ic_cross: UIImageView!
    
    @IBOutlet weak var ui_label_content: UILabel!
    @IBOutlet weak var ui_btn_no: UIButton!
    @IBOutlet weak var ui_btn_yes: UIButton!
    var content: String = ""
    var actionType: String? = ""
    var actionId:Int? = 0
    override func viewDidLoad() {
        ui_label_content.text = "custom_dialog_action_content_one_demande".localized
        super.viewDidLoad()
        ui_label_content.attributedText = stylizeContentDemand()
        ic_cross.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked(tapGestureRecognizer:)))
        ic_cross.addGestureRecognizer(tapGestureRecognizer)
        self.ui_btn_yes.addTarget(self, action: #selector(onYesClicked), for: .touchUpInside)
        self.ui_btn_no.addTarget(self, action: #selector(onNoClicked), for: .touchUpInside)

    }
    
    @objc func onCrossClicked(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            
        }
    }
    
    
    func setContent(content:String){
        self.content = content
        
    }
    
    func setActionId(actionId:Int?){
        self.actionId = actionId
    }
    
    func setActionType(actionType:String?){
        self.actionType = actionType
    }
    
    @objc func onYesClicked(){
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedOneVC") as? ActionPassedOneVC {
                    if self.actionId != nil {
                        vc.setActionId(id: self.actionId!)
                    }
                    if self.actionType != nil {
                        vc.setActionType(actionType: self.actionType!)
                    }
                    if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                        currentVc.present(vc, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func onNoClicked(){
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                let sb = UIStoryboard.init(name: StoryboardName.main, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "ActionPassedTwoVC") as? ActionPassedTwoVC {
                    if self.actionId != nil {
                        vc.setActionId(id: self.actionId!)
                    }
                    if self.actionType != nil {
                        vc.setActionType(actionType: self.actionType!)
                    }
                    
                    if let currentVc = AppState.getTopViewController() as? HomeMainViewController{
                        currentVc.present(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func stylizeContentDemand() -> NSAttributedString {
        let baseString = "custom_dialog_action_content_one_demande".localized
        let formattedString = String(format: baseString, self.content)
        
        let attributedString = NSMutableAttributedString(string: formattedString)
        
        let range = (formattedString as NSString).range(of: self.content)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: self.ui_label_content.font.pointSize), range: range)
        
        return attributedString
    }
}


