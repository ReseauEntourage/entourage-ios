//
//  ReportGroupChoosePageViewController.swift
//  entourage
//
//  Created by Clement entourage on 22/02/2023.
//

import Foundation
import UIKit

enum ParamSupressType {
    case message
    case commment
    case publication
    case action
}

class ReportGroupChoosePageViewController:UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    //Variable
    var table_dto = [ReportCellType]()
    var event:Event? = nil
    var group:Neighborhood? = nil
    var signalType:GroupDetailSignalType = .group
    
    var eventId:Int? = nil
    var groupId:Int? = nil
    var postId:Int? = nil
    var actionId:Int? = nil
    var conversationId:Int? = nil
    var userId:Int = 0
    var chatMessageId:Int? = nil
    var analyticsClickName = ""
    var textString:String? = nil
    
    var reportVc:ReportGroupViewController? = nil
    weak var delegate:ReportGroupPageDelegate? = nil
    
    override func viewDidLoad() {
        
        ui_tableview.register(ReportChooseViewCell.nib, forCellReuseIdentifier: "ReportChooseViewCell")
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        ui_tableview.separatorStyle = .none
        loadDTO()
    }
    
    func loadDTO(){
        if textString != nil && textString != ""{
            table_dto.append(.copy)
        }
        if checkIsMe() {
            table_dto.append(.suppress)
        }else{
            table_dto.append(.report)
        }
        if checkparameterType() == .commment && !checkIsMe() {
            table_dto.append(.translate)
        }
        
        ui_tableview.reloadData()
    }
    func checkIsMe() -> Bool{
        if let _myId = UserDefaults.currentUser?.uuid{
            if _myId == String(self.userId) {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func checkparameterType() -> ParamSupressType{
        if (groupId != nil || eventId != nil) && chatMessageId != nil {
            return .commment
        }else if chatMessageId != nil && groupId == nil && eventId == nil{
            return.message
        }else{
            return .publication
        }
        return .publication
    }
}

extension ReportGroupChoosePageViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table_dto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if actionId != nil {
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row], paramType: .action)
                return cell
            }
        }
        switch(table_dto[indexPath.row]){
        case .report:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row], paramType: checkparameterType())
                return cell
            }
            
        case .suppress:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row], paramType: checkparameterType())
                return cell
            }
        case .translate:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row], paramType: checkparameterType())
                return cell
            }
        case .copy:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row], paramType: checkparameterType())
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch table_dto[indexPath.row]{
        case .report:
            delegate?.chooseReport()
        case .suppress:
            showAlert()
        case .translate:
            delegate?.translateItem(id: chatMessageId!)
        case .copy:
            delegate?.copyItemText()
        }
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
        let buttonCancel = MJAlertButtonType(title: "eventCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "supress_button_title".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: alerteTitle, message: alerteText, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
    }
    
}

extension ReportGroupChoosePageViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        AnalyticsLoggerManager.logEvent(name: self.analyticsClickName)
        if let _groupId = groupId, let _postId = postId {
            NeighborhoodService.deletePostMessage(groupId: _groupId, messageId: _postId) { error in
                if error == nil {
                    self.delegate?.closeMainForDelete()
                }
            }
        }
        if let _eventId = eventId , let _postId = postId{
            EventService.deletePostMessage(eventId: _eventId, messageId: _postId) { error in
                self.delegate?.closeMainForDelete()
            }
        }
        if let _chatmessageId = chatMessageId {
            MessagingService.deletetCommentFor(chatMessageId: _chatmessageId) { error in
                self.delegate?.closeMainForDelete()
            }
        }
    }
}
