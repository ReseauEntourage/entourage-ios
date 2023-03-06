//
//  ReportGroupChoosePageViewController.swift
//  entourage
//
//  Created by Clement entourage on 22/02/2023.
//

import Foundation
import UIKit

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
        table_dto.append(.report)
        if checkIsMe() {
            table_dto.append(.suppress)
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
}

extension ReportGroupChoosePageViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table_dto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch(table_dto[indexPath.row]){
        case .report:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row])
                return cell
            }
            
        case .suppress:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "ReportChooseViewCell", for: indexPath ) as? ReportChooseViewCell {
                cell.selectionStyle = .none
                cell.populate(type: table_dto[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch table_dto[indexPath.row]{
        case .report:
            delegate?.chooseReport()
        case .suppress:
            showAlert()
        }
    }
    
    func showAlert(){
        AnalyticsLoggerManager.logEvent(name: Click_delete_post)
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "eventCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .orange), bgColor: .appOrangeLight_70, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "supress_button_title".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "supress_alert_title".localized, message: "supress_alert_text".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
    }
    
    
}

extension ReportGroupChoosePageViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        AnalyticsLoggerManager.logEvent(name: Delete_post)
        guard let _postId = postId else {
            return
        }
        if let _groupId = groupId {
            NeighborhoodService.deletePostMessage(groupId: _groupId, messageId: _postId) { error in
                if error == nil {
                    self.delegate?.closeMainForDelete()
                }
            }
        }
        if let _eventId = eventId {
            EventService.deletePostMessage(eventId: _eventId, messageId: _postId) { error in
                self.delegate?.closeMainForDelete()
            }
        }
    }
}
