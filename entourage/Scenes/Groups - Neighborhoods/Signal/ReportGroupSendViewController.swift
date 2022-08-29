//
//  ReportUserSendViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportGroupSendViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_mandatory: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_bt_back: UIButton!
    @IBOutlet weak var ui_bt_send: UIButton!
    @IBOutlet weak var ui_tv_message: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    
    
    let placeholderBioTxt = "report_group_placeholder".localized
    let placeholderBioColor = UIColor.lightGray
    let bioColor = UIColor.black
    
    var event:Event? = nil
    var group:Neighborhood? = nil
    var signalType:GroupDetailSignalType = .group
    
    var eventId:Int? = nil
    var groupId:Int? = nil
    var postId:Int? = nil
    var actionId:Int? = nil
    var conversationId:Int? = nil
    
    var tagsignals:Tags! = nil
    weak var pageDelegate:ReportGroupPageDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: à traduire les textes en fonction du type -> signalType
        
        //TODO: on affiche le fond transparent pour l'alerte ou un fond blanc ?
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_description.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_description.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        ui_description.text = "report_group_message_description".localized
        
        ui_lbl_mandatory.font = ApplicationTheme.getFontLegend().font
        ui_lbl_mandatory.textColor = ApplicationTheme.getFontLegend().color
        ui_lbl_mandatory.text = "report_group_optional".localized
        
        ui_bt_send.titleLabel?.font = ApplicationTheme.getFontBoutonBlanc().font
        ui_bt_send.titleLabel?.textColor = ApplicationTheme.getFontBoutonBlanc().color
        ui_bt_send.layer.cornerRadius = ui_bt_send.frame.height / 2
        ui_bt_send.setTitle("report_group_validate_button".localized, for: .normal)
        ui_bt_send.backgroundColor = .appOrange
        
        ui_bt_back.titleLabel?.font = ApplicationTheme.getFontBoutonOrange().font
        ui_bt_back.titleLabel?.textColor = ApplicationTheme.getFontBoutonOrange().color
        ui_bt_back.layer.cornerRadius = ui_bt_back.frame.height / 2
        ui_bt_back.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_back.layer.borderWidth = 1
        ui_bt_back.setTitle("report_group_back_button".localized, for: .normal)
        ui_bt_back.backgroundColor = .white
        
        ui_tv_message.placeholderText = placeholderBioTxt
        ui_tv_message.placeholderColor = placeholderBioColor
        
        ui_tv_message.delegate = self
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb))
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        ui_tv_message.addToolBar(width: _width, buttonValidate: buttonDone)
    }

    @objc func closeKb() {
        let _ = ui_tv_message.resignFirstResponder()
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        reportUser(message: ui_tv_message.text)
    }
    
    @IBAction func action_back(_ sender: Any) {
        pageDelegate?.goBack()
    }
    
    //MARK: - Network -
    func reportUser(message:String?) {
        let tagsSignalsWS = tagsignals.getTagsForWS()
        
        switch signalType {
        case .group:
            guard let group = group else {
                return
            }
            NeighborhoodService.reportNeighborhood(groupId:group.uid, message: message, tags: tagsSignalsWS) { error in
                DispatchQueue.main.async {
                    self.pageDelegate?.closeMain()
                }
            }
        case .event:
            guard let event = event else {
                return
            }
            EventService.reportEvent(eventId: event.uid, message: message, tags: tagsSignalsWS) { error in
                DispatchQueue.main.async {
                    self.pageDelegate?.closeMain()
                }
            }
        case .comment,.publication:
            let isPost = signalType == .publication
            
            if eventId != nil {
                guard let eventId = eventId, let postId = postId else {
                    return
                }
                EventService.reportEventPost(eventId: eventId, postId: postId, message: message, tags: tagsSignalsWS, isPost: isPost) { error in
                    DispatchQueue.main.async {
                        self.pageDelegate?.closeMain()
                    }
                }
            }
            else {
                guard let groupId = groupId, let postId = postId else {
                    return
                }
                NeighborhoodService.reportNeighborhoodPost(groupId:groupId, postId: postId, message: message, tags: tagsSignalsWS, isPost: isPost) { error in
                    DispatchQueue.main.async {
                        self.pageDelegate?.closeMain()
                    }
                }
            }
        case .actionContrib,.actionSolicitation:
            guard let actionId = actionId else {
                return
            }
            let isContrib = signalType == .actionContrib
            ActionsService.reportActionPost(isContrib: isContrib, actionId: actionId, message: message, tags: tagsSignalsWS) { error in
                DispatchQueue.main.async {
                    self.pageDelegate?.closeMain()
                }
            }
        case .conversation:
            guard let conversationId = conversationId else {
                return
            }

            MessagingService.reportConversation(conversationId: conversationId, message: message, tags: tagsSignalsWS) { error in
                DispatchQueue.main.async {
                    self.pageDelegate?.closeMain()
                }
            }
        }
    }
    
    func showError(message:String, imageName:String? = nil) {
        ui_error_view.changeTitleAndImage(title: message,imageName: imageName)
        ui_error_view.show()
    }
}

//MARK: - UITextViewDelegate -
extension ReportGroupSendViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //TODO: ON garde quel comportement? avec ou sans retour à la ligne ?
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
