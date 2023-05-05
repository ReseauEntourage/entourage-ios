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

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
