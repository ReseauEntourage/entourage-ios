//
//  ActionParamsCGUViewController.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit

class ActionParamsCGUViewController: UIViewController {
    
    @IBOutlet weak var ui_view_top: MJNavBackView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var arrayDesc = [String]()
    var arrayTitle = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayDesc = ["action_CGU_1".localized,"action_CGU_2".localized,
                     "action_CGU_3".localized,"action_CGU_4".localized,"action_CGU_5".localized]
        
        arrayTitle = ["action_CGU_1_title".localized,"action_CGU_2_title".localized,
                      "action_CGU_3_title".localized,"action_CGU_4_title".localized,"action_CGU_5_title".localized]
        
        ui_view_top.populateView(title: "action_params_cgu_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        ui_title.text = "action_params_cgu_description".localized
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        
        AnalyticsLoggerManager.logEvent(name: View_GroupOption_Rules)
    }
}

extension ActionParamsCGUViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodCguCell
        
        cell.populateCell(title: arrayTitle[indexPath.row], description: arrayDesc[indexPath.row])
        
        return cell
    }
}

extension ActionParamsCGUViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}
