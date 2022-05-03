//
//  ReportUserPageViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportGroupPageViewController: UIPageViewController {
    
    var group:Neighborhood? = nil
    var signalType:GroupDetailSignalType = .group
    
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
                reportVc?.group = group
                reportVc?.signalType = signalType
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
            sendVc.signalType = signalType
            setViewControllers([sendVc], direction: .forward, animated: true)
        }
    }
    
    func goBack() {
        guard let reportVc = reportVc else { return }
        setViewControllers([reportVc], direction: .reverse, animated: true)
    }
    
    func closeMain() {
        self.parentDelegate?.showMessage(message: "report_group_message_success".localized, imageName: "ic_partner_follow_on")
        self.parent?.dismiss(animated: true)
    }
}

//MARK: - Protocol ReportUserPageDelegate -
protocol ReportGroupPageDelegate: AnyObject {
    func goBack()
    func goNext(tags:Tags)
    func closeMain()
}
