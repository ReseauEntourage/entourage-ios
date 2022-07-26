//
//  EventParamsCGUViewController.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamsCGUViewController: UIViewController {

    @IBOutlet weak var ui_view_top: MJNavBackView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var arrayDesc = [String]()
    var arrayTitle = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayDesc = ["event_CGU_1".localized,"event_CGU_2".localized,
                     "event_CGU_3".localized,"event_CGU_4".localized]
        
        arrayTitle = ["event_CGU_1_title".localized,"event_CGU_2_title".localized,
                      "event_CGU_3_title".localized,"event_CGU_4_title".localized]
        
        ui_view_top.populateView(title: "event_params_cgu_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        ui_title.text = "event_params_cgu_description".localized
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        
        AnalyticsLoggerManager.logEvent(name: View_GroupOption_Rules)
    }
}

extension EventParamsCGUViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodCguCell
        
        cell.populateCell(title: arrayTitle[indexPath.row], description: arrayDesc[indexPath.row], position: indexPath.row + 1)
        
        return cell
    }
}


extension EventParamsCGUViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}
