//
//  OTHomeLightHelpViewController.swift
//  entourage
//
//  Created by Jr on 12/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoHelpViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _message:String = OTLocalisationService.getLocalizedValue(forKey: "home_neo_help_title")
        let _mess_Orange:String = OTLocalisationService.getLocalizedValue(forKey: "home_neo_help_title_bold")
        let _title = Utilitaires.formatString(stringMessage: _message, coloredTxt: _mess_Orange, color: .black, colorHighlight: UIColor.appOrange(), fontSize: 30.0, fontWeight: .regular, fontColoredWeight: .regular)
        
        self.ui_title.attributedText = _title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension OTHomeNeoHelpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! OTHomeNeoCell
        switch indexPath.row {
        case 0:
            cell.populateCell(cellType: .Orange, title: "home_neo_help_cell1_title", description: "home_neo_help_cell1_description", imageNamed: "picto_help_1", buttonTitle: "home_neo_help_cell1_button")
        case 1:
            cell.populateCell(cellType: .White, title: "home_neo_help_cell2_title", description: "home_neo_help_cell2_description", imageNamed: "picto_help_2", buttonTitle: "home_neo_help_cell2_button")
        case 2:
            cell.populateCell(cellType: .White, title: "home_neo_help_cell3_title", description: "home_neo_help_cell3_description", imageNamed: "picto_help_3", buttonTitle: "home_neo_help_cell3_button")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoStreet") {
                self.navigationController?.pushViewController(vc, animated: true)
                OTLogger.logEvent(Action_NeoFeedFirst_Training)
            }
        }
        
        if indexPath.row == 1 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoTourStart") {
                self.navigationController?.pushViewController(vc, animated: true)
                OTLogger.logEvent(Action_NeoFeedFirst_Tour)
            }
        }
        if indexPath.row == 2 {
            let sb = UIStoryboard.init(name: "Main2", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "OTMain0")  as! OTFeedsViewController
            vc.isFromEvent = true
            vc.titleFrom = OTLocalisationService.getLocalizedValue(forKey: "outings_title_home")
            self.navigationController?.pushViewController(vc, animated: true)
            OTLogger.logEvent(Action_NeoFeedFirst_Events)
        }
    }
}
