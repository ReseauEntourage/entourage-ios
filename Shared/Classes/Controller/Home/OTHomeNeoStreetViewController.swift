//
//  OTHomeNeoStreetViewController.swift
//  entourage
//
//  Created by Jr on 12/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoStreetViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_neo_street_title")
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_street_subtitle")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension OTHomeNeoStreetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! OTHomeNeoCell
        switch indexPath.row {
        case 0:
            cell.populateCell(cellType: .Orange, title: "home_neo_street_cell1_title", description: "home_neo_street_cell1_description", imageNamed: "picto_understand1", buttonTitle: "home_neo_street_cell1_button")
        case 1:
            cell.populateCell(cellType: .White, title: "home_neo_street_cell2_title", description: "home_neo_street_cell2_description", imageNamed: "picto_understand2", buttonTitle: "home_neo_street_cell2_button")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let url = OTSafariService.redirectUrl(withIdentifier: SLUG_EVENT_BRITE) {
                OTSafariService.launchInAppBrowser(with: url)
                OTLogger.logEvent(Action_NeoFeedFirst_OnlineTraining)
            }
        }
        
        if indexPath.row == 1 {
            if let url = OTSafariService.redirectUrl(withIdentifier: SLUG_ACTION_SCB) {
                OTSafariService.launchInAppBrowser(with: url)
                OTLogger.logEvent(Action_NeoFeedFirst_SCBonjour)
            }
        }
    }
}
