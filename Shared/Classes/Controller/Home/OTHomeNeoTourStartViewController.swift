//
//  OTHomeNeoTourStartViewController.swift
//  entourage
//
//  Created by Jr on 13/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoTourStartViewController: UIViewController {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_view_button_next: UIView!
    @IBOutlet weak var ui_button_title: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_view_container.layer.borderWidth = 2
        ui_view_container.layer.borderColor = UIColor.appOrange()?.cgColor
        ui_view_container.layer.cornerRadius = 4
        
        ui_view_button_next.layer.cornerRadius = 4
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_start_top_title")
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_start_title")
        
        ui_button_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_start_button_title")
    }
    
    @IBAction func action_next(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoTourList") {
            self.navigationController?.pushViewController(vc, animated: true)
            OTLogger.logEvent(Action_NeoFeedFirst_GoTour)
        }
    }
}

extension OTHomeNeoTourStartViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OTHomeTourCell
        
        cell.populateCell(position: indexPath.row)
        
        return cell
    }
}

class OTHomeTourCell: UITableViewCell {
    
    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    
    func populateCell(position:Int) {
        var pictoTxt = ""
        var titleTxt = ""
        switch position {
        case 0:
            pictoTxt = "picto_maraude_neo_1"
            titleTxt = "home_neo_tour_start_info1"
        case 1:
            pictoTxt = "picto_maraude_neo_2"
            titleTxt = "home_neo_tour_start_info2"
        case 2:
            pictoTxt = "picto_maraude_neo_3"
            titleTxt = "home_neo_tour_start_info3"
        case 3:
            pictoTxt = "picto_maraude_neo_4"
            titleTxt = "home_neo_tour_start_info4"
        case 4:
            pictoTxt = "picto_maraude_neo_5"
            titleTxt = "home_neo_tour_start_info5"
        default:
            break
        }
        
        ui_picto.image = UIImage.init(named: pictoTxt)
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: titleTxt) 
    }
}
