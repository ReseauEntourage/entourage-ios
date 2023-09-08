//
//  ReportUserMainViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportGroupMainViewController: BasePopViewController {
    
    var group:Neighborhood? = nil
    var event:Event? = nil
    var signalType:GroupDetailSignalType = .group
    
    var eventId:Int? = nil
    var groupId:Int? = nil
    var postId:Int? = nil
    var actionId:Int? = nil
    var userId:Int? = 0
    var conversationId:Int? = nil
    var messageId:Int? = nil
    var analyticsClickName = ""

    
    weak var parentDelegate:GroupDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (groupId != nil || eventId != nil) && messageId != nil {
            ui_top_view.populateView(title: "parameter_comment".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        }else if messageId != nil && groupId == nil && eventId == nil{
            ui_top_view.populateView(title: "parameter_message".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        }else if actionId != nil {
            ui_top_view.populateView(title: "parameter_action".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        }else{
            ui_top_view.populateView(title: "parameter_publication".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        }
        setTitleForSignalementFromMainGroup()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if checkIsMe(){
            self.view.isHidden = true
            showAlert()
        }else{
            if let vc = segue.destination as? ReportGroupPageViewController {
                vc.group = self.group
                vc.event = event
                vc.signalType = signalType
                vc.parentDelegate = parentDelegate
                vc.groupId = groupId
                vc.postId = postId
                vc.eventId = eventId
                vc.userId = userId
                vc.actionId = actionId
                vc.messageId = messageId
                vc.conversationId = conversationId
                vc.titleDelegate = self
            }
        }
    }
    func setTitleForSignalementFromMainGroup() {
        var _title = "report_group_title".localized
        switch signalType {
        case .group:
            _title = "report_group_title".localized
        case .comment:
            _title = "report_comment_title".localized
        case .publication:
            _title = "report_publication_title".localized
        case .event:
            _title = "report_event_title".localized
        case .actionContrib:
            _title = "report_contrib_title".localized
        case .actionSolicitation:
            _title = "report_solicitation_title".localized
        case .conversation:
            _title = "report_conversation_title".localized
        }
        ui_top_view.populateView(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
    }
}

//MARK: - MJNavBackViewDelegate -
extension ReportGroupMainViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - Protocol UserProfileDetailDelegate -
protocol GroupDetailDelegate: AnyObject {
    func showMessage(signalType:GroupDetailSignalType)
    func publicationDeleted()
}

enum GroupDetailSignalType {
    case group
    case comment
    case publication
    case event
    case actionContrib
    case actionSolicitation
    case conversation
}

protocol TitleDelegate{
    func setTitleForSignal()
    
}

extension ReportGroupMainViewController : TitleDelegate{
    func setTitleForSignal() {
        var _title = "report_group_title".localized
        switch signalType {
        case .group:
            _title = "report_group_title".localized
        case .comment:
            _title = "report_comment_title".localized
        case .publication:
            _title = "report_publication_title".localized
        case .event:
            _title = "report_event_title".localized
        case .actionContrib:
            _title = "report_contrib_title".localized
        case .actionSolicitation:
            _title = "report_solicitation_title".localized
        case .conversation:
            _title = "report_conversation_title".localized
        }
        ui_top_view.populateView(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
    }
}

extension ReportGroupMainViewController{
    func checkIsMe() -> Bool{
        if let _myId = UserDefaults.currentUser?.uuid{
            if self.userId != nil {
                if _myId == String(self.userId!) {
                    return true
                }else{
                    return false
                }
            }
        }else{
            return false
        }
        return false
    }
    
    func checkparameterType() -> ParamSupressType{
        if (groupId != nil || eventId != nil) && messageId != nil {
            return .commment
        }else if messageId != nil && groupId == nil && eventId == nil{
            return.message
        }else{
            return .publication
        }
        return .publication
    }
    func showAlert(){
        var alerteTitle = ""
        var alerteText = ""
        var analyticsName = ""
        switch(checkparameterType()){
        case .message:
            alerteTitle = "supress_alert_title_message".localized
            alerteText = "supress_alert_text_message".localized
            analyticsName = Click_delete_mess
            self.analyticsClickName = Delete_mess
        case .commment:
            alerteTitle = "supress_alert_title_comment".localized
            alerteText = "supress_alert_text_comment".localized
            analyticsName = Click_delete_comm
            self.analyticsClickName = Delete_comm
        case .publication:
            alerteTitle = "supress_alert_title_publi".localized
            alerteText = "supress_alert_text_publi".localized
            analyticsName = Click_delete_post
            self.analyticsClickName = Delete_post

        case .action:
            alerteTitle = "supress_alert_title_publi".localized
            alerteText = "supress_alert_text_publi".localized
            analyticsName = Click_delete_post
            self.analyticsClickName = Delete_post
        }
        
        AnalyticsLoggerManager.logEvent(name: analyticsName)
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "eventCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontBoutonBlanc(size: 15, color: .orange), bgColor: .appOrangeLight_70, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "supress_button_title".localized, titleStyle:ApplicationTheme.getFontBoutonBlanc(size: 15, color: .white), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: alerteTitle, message: alerteText, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
    }
}

extension ReportGroupMainViewController:MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.parentDelegate?.publicationDeleted()
        self.parent?.dismiss(animated: true)
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        AnalyticsLoggerManager.logEvent(name: self.analyticsClickName)
        if let _groupId = groupId, let _postId = postId {
            NeighborhoodService.deletePostMessage(groupId: _groupId, messageId: _postId) { error in
                if error == nil {
                    self.parentDelegate?.publicationDeleted()
                    self.parent?.dismiss(animated: true)
                }
            }
        }
        if let _eventId = eventId , let _postId = postId{
            EventService.deletePostMessage(eventId: _eventId, messageId: _postId) { error in
                self.parentDelegate?.publicationDeleted()
                self.parent?.dismiss(animated: true)
            }
        }
        if let _chatmessageId = messageId {
            MessagingService.deletetCommentFor(chatMessageId: _chatmessageId) { error in
                self.parentDelegate?.publicationDeleted()
                self.parent?.dismiss(animated: true)
            }
        }
    }
}

