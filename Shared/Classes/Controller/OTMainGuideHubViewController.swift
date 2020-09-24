//
//  OTMainGuideHubViewController.swift
//  entourage
//
//  Created by Jr on 22/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTMainGuideHubViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! CellGeneric
            cell.populateCell(position: 3)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            showGds()
        case 1:
            showWeb(slug: SLUG_HUB_LINK_1)
        case 2:
           showWeb(slug: SLUG_HUB_LINK_2)
            
        default:
            showWeb(slug: SLUG_HUB_LINK_3)
        }
    }
}

//MARK: - Custom Cell Hub -
class CellGeneric: UITableViewCell {
    @IBOutlet weak var ui_image: UIImageView?
    
    @IBOutlet weak var ui_label_title: UILabel?
    @IBOutlet weak var ui_label_subtitle: UILabel?
    
    @IBOutlet weak var ui_label_description: UILabel?
    @IBOutlet weak var ui_label_button: UILabel?
    
    
    @IBOutlet weak var ui_view_button: UIView?
    
    @IBOutlet weak var ui_view_corner: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_corner?.layer.cornerRadius = 8
        ui_image?.layer.cornerRadius = 8
        ui_view_button?.layer.cornerRadius = 5
    }
    
    func populateCell(position:Int) {
        switch position {
        case 0:
            ui_label_title?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_title_1")
            ui_label_subtitle?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_subtitle_1")
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
        default:
            ui_label_button?.text = OTLocalisationService.getLocalizedValue(forKey: "hub_button_4").uppercased()
        }
    }
}
