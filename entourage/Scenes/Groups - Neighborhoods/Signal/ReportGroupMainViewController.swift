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
    
    weak var parentDelegate:GroupDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        
        ui_top_view.populateView(title: _title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
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
}

enum GroupDetailSignalType {
    case group
    case comment
    case publication
    case event
}
