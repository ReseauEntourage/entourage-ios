//
//  ReportUserPageViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//
import Foundation
import UIKit

class ReportGroupPageViewController: UIPageViewController {
    
    var event:Event? = nil
    var group:Neighborhood? = nil
    var signalType:GroupDetailSignalType = .group
    
    var eventId:Int? = nil
    var groupId:Int? = nil
    var postId:Int? = nil
    var actionId:Int? = nil
    var userId:Int? = nil
    var conversationId:Int? = nil
    var haveChosen = false
    var titleDelegate:TitleDelegate? = nil
    var messageId:Int? = nil
    var analyticsClickName = ""

    
    var reportVc:ReportGroupViewController? = nil
    var chooseVc:ReportGroupChoosePageViewController? = nil
    weak var parentDelegate:GroupDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isPagingEnabled = false
        
        reportVc = viewController(isSend:false) as? ReportGroupViewController
        
        guard let reportVc = reportVc else {
            return
        }

        if checkIsMe() {
            self.goBack()
        }else{
            haveChosen = true
            self.titleDelegate?.setTitleForSignal()
            setViewControllers([reportVc], direction: .forward, animated: true)
        }
    }
    
    func viewController(isSend:Bool) -> UIViewController? {
        if !isSend {
            if reportVc == nil {
                reportVc = storyboard?.instantiateViewController(withIdentifier: "reportGroupSignalVC") as? ReportGroupViewController
                reportVc?.pageDelegate = self
            }
            return reportVc
        }
        else {
            let sendVC = storyboard?.instantiateViewController(withIdentifier: "reportGroupSendVC") as! ReportGroupSendViewController
            return sendVC
        }
    }
}

//MARK: - ReportUserPageDelegate -
extension ReportGroupPageViewController: ReportGroupPageDelegate {
    func chooseReport() {
        haveChosen = true
        self.titleDelegate?.setTitleForSignal()
        setViewControllers([reportVc!], direction: .forward, animated: true)
    }
    
    
    func chooseType(){
        if !haveChosen {
            if chooseVc == nil {
                chooseVc = storyboard?.instantiateViewController(withIdentifier: "reportChooseGroupVC") as? ReportGroupChoosePageViewController
                setViewControllers([chooseVc!], direction: .forward, animated: true)
            }
        }
    }
    
    
    func goNext(tags:Tags) {
        if let sendVc = viewController(isSend: true) as? ReportGroupSendViewController {
            sendVc.tagsignals = tags
            sendVc.pageDelegate = self
            sendVc.group = self.group
            sendVc.event = self.event
            sendVc.signalType = signalType
            sendVc.postId = postId
            sendVc.groupId = groupId
            sendVc.eventId = self.eventId
            sendVc.actionId = self.actionId
            sendVc.conversationId = self.conversationId
            setViewControllers([sendVc], direction: .forward, animated: true)
        }
    }
    
    func goBack() {
        guard let reportVc = reportVc else { return }
        setViewControllers([reportVc], direction: .reverse, animated: true)
    }
    
    func closeMain() {
        self.parentDelegate?.showMessage(signalType: signalType)
        self.parent?.dismiss(animated: true)
        
    }
    func closeMainForDelete() {
        self.parentDelegate?.publicationDeleted()
        self.parent?.dismiss(animated: true)

    }
}

//MARK: - Protocol ReportUserPageDelegate -
protocol ReportGroupPageDelegate: AnyObject {
    func goBack()
    func goNext(tags:Tags)
    func closeMain()
    func closeMainForDelete()
    func chooseReport()
}


extension ReportGroupPageViewController{

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

extension ReportGroupPageViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
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
