//
//  ReportUserPageViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportGroupPageViewController: UIPageViewController {
    
    var event:Event? = nil
    var group:Neighborhood? = nil
    var signalType:GroupDetailSignalType = .group
    
    var eventId:Int? = nil
    var groupId:Int? = nil
    var postId:Int? = nil
    var actionId:Int? = nil
    
    var reportVc:ReportGroupViewController? = nil
    weak var parentDelegate:GroupDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isPagingEnabled = false
        
        reportVc = viewController(isSend:false) as? ReportGroupViewController
        
        guard let reportVc = reportVc else {
            return
        }
        
        setViewControllers([reportVc], direction: .forward, animated: true)
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
}

//MARK: - Protocol ReportUserPageDelegate -
protocol ReportGroupPageDelegate: AnyObject {
    func goBack()
    func goNext(tags:Tags)
    func closeMain()
}
