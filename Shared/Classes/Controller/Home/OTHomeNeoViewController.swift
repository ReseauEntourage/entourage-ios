//
//  OTHomeLightViewController.swift
//  entourage
//
//  Created by Jr on 07/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoViewController: UIViewController {
    
    @IBOutlet weak var ui_view_top: UIView!
    @IBOutlet weak var ui_title_neo: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var isAllreadyCheckCountNeo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ui_view_top.layer.shadowColor = UIColor.black.cgColor
        self.ui_view_top.layer.shadowOpacity = 0.5
        self.ui_view_top.layer.shadowRadius = 2.0
        self.ui_view_top.layer.masksToBounds = false
        
        let _rect = CGRect(x: 0, y: self.ui_view_top.bounds.size.height , width: self.view.frame.size.width, height: self.ui_view_top.layer.shadowRadius)
        let _shadowPath = UIBezierPath(rect: _rect).cgPath
        self.ui_view_top.layer.shadowPath = _shadowPath
        
        self.ui_title_neo.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_title_neo")
        
        OTLogger.logEvent(View_Start_NeoFeed)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkProfile()
    }
    
    func checkProfile() {
        
        let isAllreadyInfoNeo:Bool = UserDefaults.standard.bool(forKey: "isAllreadyInfoNeo")
        
        if !isAllreadyInfoNeo {
            UserDefaults.standard.setValue(true, forKey: "isAllreadyInfoNeo")
            if let currentUser = UserDefaults.standard.currentUser {
                if currentUser.isUserTypeNeighbour() && !currentUser.isEngaged {
                    let message = OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_info_message")
                    
                    let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_info_title"), message: message, preferredStyle: .alert)
                    
                    let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_info_button_profil"), style: .default) { (action) in
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
                        DispatchQueue.main.async {
                            alertVC.dismiss(animated: false, completion: nil)
                        }
                    }
                    
                    let actionCancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_info_button_ok"), style: .default,handler: nil)
                    
                    alertVC.addAction(actionCancel)
                    alertVC.addAction(action)
                    
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
        else {
            if isAllreadyCheckCountNeo {
                return
            }
            isAllreadyCheckCountNeo = true
            if let currentUser = UserDefaults.standard.currentUser {
                if currentUser.isUserTypeNeighbour() && !currentUser.isEngaged {
                    var countPop = UserDefaults.standard.integer(forKey: "countPopNeoMode")
                    if countPop >= 2 {
                        UserDefaults.standard.setValue(0, forKey: "countPopNeoMode")
                        
                        let message = OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_goExpert_message")
                        
                        let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_goExpert_title"), message: message, preferredStyle: .alert)
                        
                        let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_goExpert_bt_ok"), style: .default) { (action) in
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
                            DispatchQueue.main.async {
                                alertVC.dismiss(animated: false, completion: nil)
                            }
                        }
                        
                        let actionCancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "home_neo_pop_goExpert_bt_cancel"), style: .default,handler: nil)
                        
                        alertVC.addAction(actionCancel)
                        alertVC.addAction(action)
                        
                        self.present(alertVC, animated: true, completion: nil)
                    }
                    else {
                        countPop = countPop + 1
                        UserDefaults.standard.setValue(countPop, forKey: "countPopNeoMode")
                    }
                }
            }
        }
    }
}

extension OTHomeNeoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + 1 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! OTHomeNeoCell
        
        if indexPath.row == 1 {
            cell.populateCell(cellType: .Orange, title: "home_neo_cell1_title", description: "home_neo_cell1_description", imageNamed: "first_try", buttonTitle: "home_neo_cell1_button")
            return cell
        }
        else if indexPath.row == 2 {
            cell.populateCell(cellType: .White, title: "home_neo_cell2_title", description: "home_neo_cell2_description", imageNamed: "agir", buttonTitle: "home_neo_cell2_button")
            return cell
        }
        
        let cellInfo = tableView.dequeueReusableCell(withIdentifier: "cellInfo", for: indexPath) as! OTHomeInfoCell
        cellInfo.populate(isNeo: true, delegate: self)
        
        return cellInfo
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoFirstHelp") {
                self.navigationController?.pushViewController(vc, animated: true)
                OTLogger.logEvent(Action_NeoFeed_FirstStep)
            }
        }
        else if indexPath.row == 2 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoAction") {
                self.navigationController?.pushViewController(vc, animated: true)
                OTLogger.logEvent(Action_NeoFeed_ActNow)
            }
        }
    }
}

extension OTHomeNeoViewController: HomeInfoDelegate {
    func showProfile() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapProfilTab"), object: nil)
    }
}
