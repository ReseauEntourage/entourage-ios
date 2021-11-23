//
//  OTMainGuideHubViewController.swift
//  entourage
//
//  Created by Jr on 22/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTMainGuideHubViewController: UIViewController {

    @IBOutlet weak var ui_view_top: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var isNeedHelp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title")
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.ui_view_top.layer.shadowColor = UIColor.black.cgColor
        self.ui_view_top.layer.shadowOpacity = 0.3
        self.ui_view_top.layer.shadowRadius = 2.0
        self.ui_view_top.layer.masksToBounds = false
        
        let _rect = CGRect(x: 0, y: self.ui_view_top.bounds.size.height , width: self.view.frame.size.width, height: self.ui_view_top.layer.shadowRadius)
        let _shadowPath = UIBezierPath(rect: _rect).cgPath
        self.ui_view_top.layer.shadowPath = _shadowPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = UserDefaults.standard.currentUser
        isNeedHelp = user?.isUserTypeAlone() ?? false
        
        ui_tableview?.reloadData()
    }
    
    func showGds() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "OTMainGuide") {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showWeb(slug:String) {
        let token = UserDefaults.standard.currentUser.token!
        let relativeUrl = String.init(format: API_URL_MENU_OPTIONS, slug,token)
        if let _BaseUrl = OTHTTPRequestManager.sharedInstance()?.baseURL?.absoluteString {
            let url = String.init(format: "%@%@",_BaseUrl ,relativeUrl)
            
            OTSafariService.launchInAppBrowser(withUrlString: url, viewController: self.navigationController)
        }
    }
}

extension OTMainGuideHubViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNeedHelp {
            return 3
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isNeedHelp {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CellGeneric
                cell.populateCell(position: 0)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CellGeneric
                cell.populateCell(position: 1)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as! CellGeneric
                cell.populateCell(position: 4)
                return cell
            }
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CellGeneric
            cell.populateCell(position: 0)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CellGeneric
            cell.populateCell(position: 1)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! CellGeneric
            cell.populateCell(position: 2)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! CellGeneric
            cell.populateCell(position: 3)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath) as! CellGeneric
            cell.populateCell(position: 4)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isNeedHelp {
            switch indexPath.row {
            case 0:
                OTLogger.logEvent(Action_guide_showGDS)
                showGds()
            case 1:
                OTLogger.logEvent(Action_guide_webOrientation)
                showWeb(slug: SLUG_HUB_LINK_1)
            default:
                OTLogger.logEvent(Action_guide_WwebFaq)
                showWeb(slug: SLUG_HUB_LINK_FAQ)
            }
            return
        }
        
        switch indexPath.row {
        case 0:
            OTLogger.logEvent(Action_guide_showGDS)
            showGds()
        case 1:
            OTLogger.logEvent(Action_guide_webOrientation)
            showWeb(slug: SLUG_HUB_LINK_1)
        case 2:
            OTLogger.logEvent(Action_guide_webGuide)
           showWeb(slug: SLUG_HUB_LINK_2)
        case 3:
            OTLogger.logEvent(Action_guide_webAtelier)
           showWeb(slug: SLUG_HUB_LINK_3)
        case 4:
            OTLogger.logEvent(Action_guide_WwebFaq)
            showWeb(slug: SLUG_HUB_LINK_FAQ)
        default:
            break
        }
    }
}

//MARK: - Custom Cell Hub -
class CellGeneric: UITableViewCell {
    @IBOutlet weak var ui_image: UIImageView?
    
    @IBOutlet weak var ui_label_title: UILabel?
    
    @IBOutlet weak var ui_label_description: UILabel?
    @IBOutlet weak var ui_label_button: UILabel?
    
    
    @IBOutlet weak var ui_view_button: UIView?
    
    @IBOutlet weak var ui_view_corner: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_corner?.layer.cornerRadius = 8
        ui_image?.layer.cornerRadius = 10
        ui_view_button?.layer.cornerRadius = 5
    }
    
    func populateCell(position:Int) {
        switch position {
        case 0:
            ui_label_title?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title_1")
            ui_label_description?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_description_1")
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_1")
        case 1:
            ui_label_title?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title_2")
            ui_label_description?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_description_2")
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_2").uppercased()
        case 2:
            ui_label_title?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title_3")
            ui_label_description?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_description_3")
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_3")
            ui_image?.layer.cornerRadius = 10
        case 3:
            ui_label_description?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_description_4")
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_4").uppercased()
        default:
            ui_label_title?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title_5")
            ui_label_description?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_description_5")
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_5").uppercased()
        }
    }
}
