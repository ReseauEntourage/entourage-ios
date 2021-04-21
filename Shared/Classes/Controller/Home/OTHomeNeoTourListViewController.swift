//
//  OTHomeNeoTourListViewController.swift
//  entourage
//
//  Created by Jr on 13/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeNeoTourListViewController: UIViewController {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    
    var arrayAreas = [OTHomeTourArea]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_areas_top_title")
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_areas_title")
        ui_description.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_areas_description")
        
        getTourList()
    }
    
    func getTourList() {
        OTHomeNeoService.getAreas { (areas, error) in
            if let _array = areas {
                self.arrayAreas.removeAll()
                self.arrayAreas.append(contentsOf: _array)
                self.ui_tableview.reloadData()
            }
        }
    }
}

extension OTHomeNeoTourListViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAreas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OTHomeTourAreaCell
        
        cell.populateCell(areaName: arrayAreas[indexPath.row].areaName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = arrayAreas[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeNeoTourSend") as? OTHomeNeoTourSendViewController {
            vc.area = area
            self.navigationController?.pushViewController(vc, animated: true)
            
            let _analytic = String.init(format: Action_NeoFeedFirst_TourCity, area.postalCode)
            OTLogger.logEvent(_analytic)
        }
    }
}

class OTHomeTourArea {
    var areaId = 0
    var areaName = ""
    var postalCode = ""
    var isActive = true
    
    class func parsingAreas(dict:[String: Any]) -> [OTHomeTourArea] {
        var array = [OTHomeTourArea]()
        
        if let _array = dict["tour_areas"] as? [[String: Any]] {
            for _area in _array {
                let tourArea = OTHomeTourArea()
                
                if let id = _area["id"] as? Int {
                    tourArea.areaId = id
                }
                if let postalCode = _area["departement"] as? String {
                    tourArea.postalCode = postalCode
                }
                if let name = _area["area"] as? String {
                    tourArea.areaName = name
                }
                if let _status = _area["status"] as? String {
                    if _status == "active" {
                        tourArea.isActive = true
                    }
                    else {
                        tourArea.isActive = false
                    }
                }
                
                if tourArea.isActive {
                    array.append(tourArea)
                }
            }
        }
        return array
    }
}

class OTHomeTourAreaCell: UITableViewCell {
    
    @IBOutlet weak var ui_mainview: UIView!
    @IBOutlet weak var ui_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_mainview.layer.cornerRadius = 4
    }
    
    func populateCell(areaName:String) {
        ui_title.text = areaName
    }
}
