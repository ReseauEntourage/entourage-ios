//
//  NeighBorhoodParamsCGUViewController.swift
//  entourage
//
//  Created by Jerome on 03/05/2022.
//

import UIKit

class NeighBorhoodParamsCGUViewController: UIViewController {
    
    @IBOutlet weak var ui_view_top: MJNavBackView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var arrayDesc = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayDesc = ["neighborhood_CGU_1".localized,"neighborhood_CGU_2".localized,
                     "neighborhood_CGU_3".localized,"neighborhood_CGU_4".localized]
        
        ui_view_top.populateView(title: "neighborhood_params_cgu_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        ui_title.text = "neighborhood_params_cgu_description".localized
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        
        AnalyticsLoggerManager.logEvent(name: View_GroupOption_Rules)
    }
}

extension NeighBorhoodParamsCGUViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodCguCell
        
        cell.populateCell(title: "Titre de la position \(indexPath.row + 1)", description: arrayDesc[indexPath.row], position: indexPath.row + 1)
        
        return cell
    }
}


extension NeighBorhoodParamsCGUViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}
