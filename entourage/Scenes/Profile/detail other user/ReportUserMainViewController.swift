//
//  ReportUserMainViewController.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class ReportUserMainViewController: BasePopViewController {
    
    var user:User? = nil
    weak var parentDelegate:UserProfileDetailDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "report_user_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReportUserPageViewController {
            vc.user = self.user
            vc.parentDelegate = parentDelegate
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension ReportUserMainViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        //nothing yet
    }
    
    func goBack() {
        self.dismiss(animated: true)
    }
}
