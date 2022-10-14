//
//  ReportUserPageViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportUserPageViewController: UIPageViewController {
    
    var user:User? = nil
    var reportVc:ReportUserViewController? = nil
    weak var parentDelegate:UserProfileDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isPagingEnabled = false
        
        reportVc = viewController(isSend:false) as? ReportUserViewController
        
        guard let reportVc = reportVc else {
            return
        }
        
        setViewControllers([reportVc], direction: .forward, animated: true)
    }
    
    func viewController(isSend:Bool) -> UIViewController? {
        if !isSend {
            if reportVc == nil {
                reportVc = storyboard?.instantiateViewController(withIdentifier: "reportUserSignalVC") as? ReportUserViewController
                reportVc?.pageDelegate = self
                reportVc?.user = user
            }
            return reportVc
        }
        else {
            let sendVC = storyboard?.instantiateViewController(withIdentifier: "reportUserSendVC") as! ReportUserSendViewController
            return sendVC
        }
    }
}

//MARK: - ReportUserPageDelegate -
extension ReportUserPageViewController: ReportUserPageDelegate {
    func goNext(tags:Tags) {
        if let sendVc = viewController(isSend: true) as? ReportUserSendViewController {
            sendVc.tagsignals = tags
            sendVc.pageDelegate = self
            sendVc.user = self.user
            setViewControllers([sendVc], direction: .forward, animated: true)
        }
    }
    
    func goBack() {
        guard let reportVc = reportVc else { return }
        setViewControllers([reportVc], direction: .reverse, animated: true)
    }
    
    func closeMain() {
        self.parentDelegate?.showMessage(message: "report_user_message_success".localized, imageName: "ic_partner_follow_on")
        self.parent?.dismiss(animated: true)
    }
}

//MARK: - Protocol ReportUserPageDelegate -
protocol ReportUserPageDelegate: AnyObject {
    func goBack()
    func goNext(tags:Tags)
    func closeMain()
}
