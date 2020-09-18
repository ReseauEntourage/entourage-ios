//
//  OTSolidarityGuideFiltersViewController2.swift
//  entourage
//
//  Created by Jr on 17/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTSolidarityGuideFiltersViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    weak var filterDelegate:OTSolidarityGuideFilterDelegate2? = nil
    
    var filters = OTSolidarityGuideFilter2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.print("***** vdl delegate \(filterDelegate)")
        
        if let _delegate = filterDelegate {
            filters = _delegate.getSolidarityFilter()
        }
        
        Logger.print("***** filters origin : \(filterDelegate?.getSolidarityFilter()) -- copy : \(filters)")
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "filters")?.uppercased()
        
        self.setupCloseModal(withTarget: self, andSelector: #selector(close))
        
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        
        let menuButton = UIBarButtonItem(title: OTLocalisationService.getLocalizedValue(forKey: "save")?.capitalized, style: .done, target: self , action: #selector(saveFilters))
        
        self.navigationItem.setRightBarButton(menuButton, animated: false)
        
        self.ui_tableview.tableFooterView = UIView(frame: .zero)
        
    }
    
    @objc func close() {
        OTLogger.logEvent("CloseFilter")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveFilters() {
        //TODO: a faire
        OTLogger.logEvent("SubmitFilterPreferences")
        var currentFilter = self.filters
        
        for i in currentFilter.arrayFilters.indices {
            currentFilter.updateValueFilter(position: i)
        }
        
        Logger.print("***** save filters -> \(currentFilter.isDefaultFilters())")
        dismiss(animated: true) {
            self.filterDelegate?.solidarityFilterChanged(currentFilter)
        }
    }
    
}

//MARK: - Tableview Datasource / Delegate
extension OTSolidarityGuideFiltersViewController: UITableViewDelegate,UITableViewDataSource, ChangeFilterGDSDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return filters.arrayFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersTopCell", for: indexPath) as! OTSoliguideTopFilterCell
            
            cell.populateCell(isPartnerOn: self.filters.showPartners, isDonatedOn: self.filters.showDonated, isVolunteerOn: self.filters.showVolunteer, delegate: self)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFilterCell", for: indexPath) as! OTSoliguideFilterCell
        
        cell.populateCell(item: filters.arrayFilters[indexPath.row],position: indexPath.row, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            
            if let headerV = view as? UITableViewHeaderFooterView {
                headerV.textLabel?.textColor = UIColor.appGreyishBrown()
                headerV.textLabel?.font = UIFont(name: "SFUIText-Medium", size: 15)
                headerV.textLabel?.textAlignment = .center
                headerV.tintColor = UIColor.appPaleGrey()
            }
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return OTLocalisationService.getLocalizedValue(forKey: "filter_solidarity_guide_categories")
        }
        return nil
    }
    
    func changeAtPosition(_ position: Int, isActive: Bool) {
        Logger.print("Change position : \(position) isActive : \(isActive)")
        
        self.filters.arrayFilters[position].active = isActive
    }
    
    func changeTop(_ position:Int,isActive:Bool) {
        Logger.print("Change Top position : \(position) isActive : \(isActive)")
        switch position {
        case 1:
            self.filters.showPartners = isActive
            if isActive {
                self.filters.showDonated = false
                self.filters.showVolunteer = false
            }
        case 2:
            self.filters.showDonated = isActive
        case 3:
            self.filters.showVolunteer = isActive
        default:
            break
        }
    }
    
    func updateTable() {
        self.ui_tableview.reloadData()
    }
    
}


class OTSoliguideFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch!
    
    weak var delegate:ChangeFilterGDSDelegate? = nil
    
    func populateCell(item:OTSolidarityGuideFilterItem2,position:Int,delegate:ChangeFilterGDSDelegate) {
        ui_label_title.text = item.title
        ui_image.image = UIImage.init(named: item.image)
        ui_switch.setOn(item.active, animated: true)
        ui_switch.tag = position
        self.delegate = delegate
    }
    
    @IBAction func action_change(_ sender: UISwitch) {
        delegate?.changeAtPosition(sender.tag, isActive: sender.isOn)
    }
}

class OTSoliguideTopFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_doante: UIView!
    @IBOutlet weak var ui_view_volunteer: UIView!
    @IBOutlet weak var ui_image_partner: UIImageView!
    @IBOutlet weak var ui_label_title_partner: UILabel!
    @IBOutlet weak var ui_switch_partner: UISwitch!
    
    @IBOutlet weak var ui_label_title_donated: UILabel!
    @IBOutlet weak var ui_switch_donated: UISwitch!
    @IBOutlet weak var ui_label_title_volunteer: UILabel!
    @IBOutlet weak var ui_switch_volunteer: UISwitch!
    
    weak var delegate:ChangeFilterGDSDelegate? = nil
    
    func populateCell(isPartnerOn:Bool, isDonatedOn:Bool, isVolunteerOn:Bool, delegate:ChangeFilterGDSDelegate) {
        
        ui_label_title_partner.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_partners")
        ui_image_partner.image = UIImage.init(named: "pin_partners_without_shadow")
        ui_switch_partner.setOn(isPartnerOn, animated: true)
        ui_switch_partner.tag = 1
        
        ui_label_title_donated.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_donate")
        ui_switch_donated.setOn(isDonatedOn, animated: true)
        ui_switch_donated.tag = 2
        
        ui_label_title_volunteer.text = OTLocalisationService.getLocalizedValue(forKey: "guide_display_volunteer")
        ui_switch_volunteer.setOn(isVolunteerOn, animated: true)
        ui_switch_volunteer.tag = 3
        
        self.delegate = delegate
        checkPartnerOn()
    }
    
    func checkPartnerOn() {
        if ui_switch_partner.isOn {
            ui_view_doante.isHidden = false
            ui_view_volunteer.isHidden = false
        }
        else {
            ui_view_doante.isHidden = true
            ui_view_volunteer.isHidden = true
        }
    }
    
    @IBAction func action_change(_ sender: UISwitch) {
        delegate?.changeTop(sender.tag, isActive: sender.isOn)
        checkPartnerOn()
        delegate?.updateTable()
    }
}

protocol ChangeFilterGDSDelegate:NSObject {
    func changeAtPosition(_ position:Int,isActive:Bool)
    func changeTop(_ position:Int,isActive:Bool)
    func updateTable()
}


struct OTSolidarityGuideFilter2 {
    var showFood = true
    var showHousing = true
    var showHeal = true
    var showRefresh = true
    var showOrientation = true
    var showCaring = true
    var showReinsertion = true
    
    var showPartners = true
    var showDonated = false
    var showVolunteer = false
    
    var arrayFilters = [OTSolidarityGuideFilterItem2]()
    
    init() {
        initArrayFilters()
    }
    
    
    private mutating func initArrayFilters() {
        
        if arrayFilters.count == 0 {
            arrayFilters = [OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyFood, active: showFood, image: "eat"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyHousing, active: showHousing, image: "housing"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyHeal, active: showHeal, image: "heal"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyRefresh, active: showRefresh, image: "water"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyOrientation, active: showOrientation, image: "orientate"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyCaring, active: showCaring, image: "lookAfterYourself"),
                            OTSolidarityGuideFilterItem2.init(key: .SolidarityGuideKeyReinsertion, active: showReinsertion, image: "reinsertYourself")]
        }
    }
    
    
    func isDefaultFilters() -> Bool {
        if self.showDonated || self.showVolunteer {
            return false
        }
        
        if !showFood || !showHousing || !showHeal || !showRefresh || !showOrientation || !showCaring || !showReinsertion || !showPartners {
            return false
        }
        
        return true
    }
    
    func toDictionary(distance:CLLocationDistance, location:CLLocationCoordinate2D) -> [AnyHashable:Any]? {
        
        let catIds = NSMutableArray()
        
        for item in self.arrayFilters {
            if item.active {
                catIds.add(Int(item.key.rawValue))
            }
        }
        
        let catValuesString = catIds.componentsJoined(by: ",")
        
        if showPartners {
            let catValuesModString = catValuesString + ",8"
            var filters = ""
            if showDonated {
                filters = "donations"
                if showVolunteer {
                    filters = filters + ",volunteers"
                }
            }
            else if showVolunteer {
                filters = "volunteers"
            }
            
            return ["latitude":location.latitude,
                    "longitude":location.longitude,
                    "category_ids":catValuesModString,
                    "distance":distance,
                    "partners_filters":filters]
        }
        
        return ["latitude":location.latitude,
                "longitude":location.longitude,
                "category_ids":catValuesString,
                "distance":distance]
    }
    
    mutating func updateValueFilter(position:Int) {
        
        let item = arrayFilters[position]
        let isActive = item.active
        
        switch item.key {
        case .SolidarityGuideKeyFood:
            self.showFood = isActive
        case .SolidarityGuideKeyHousing:
            self.showHousing = isActive
        case .SolidarityGuideKeyHeal:
            self.showHeal = isActive
        case .SolidarityGuideKeyRefresh:
            self.showRefresh = isActive
        case .SolidarityGuideKeyOrientation:
            self.showOrientation = isActive
        case .SolidarityGuideKeyCaring:
            self.showCaring = isActive
        case .SolidarityGuideKeyReinsertion:
            self.showReinsertion = isActive
        case .SolidarityGuideKeyPartners:
            self.showPartners = isActive
        default:
            break
        }
    }
}

@objc class OTSolidarityGuideFilterItem2:NSObject {
    var key:SolidarityGuideFilters2 = .none
    var active = false
    var title = ""
    var image = ""
    
    init(key:SolidarityGuideFilters2, active:Bool, image:String) {
        self.key = key
        self.active = active
        self.image = image
        self.title = OTSolidarityGuideFilterItem2.categoryStringForKey(key: key)
    }
    
    
    @objc static func categoryStringForKey(key:SolidarityGuideFilters2) -> String {
        switch (key) {
        case .SolidarityGuideKeyFood:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_feed")
        case .SolidarityGuideKeyHousing:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_housing")
        case .SolidarityGuideKeyHeal:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_heal")
        case .SolidarityGuideKeyRefresh:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_refresh")
        case .SolidarityGuideKeyOrientation:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_orientation")
        case .SolidarityGuideKeyCaring:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_caring")
        case .SolidarityGuideKeyReinsertion:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_reinsertion")
        case .SolidarityGuideKeyPartners:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_partners")
        default:
            return ""
        }
    }
    
}

@objc enum SolidarityGuideFilters2:Int {
    case SolidarityGuideKeyFood = 1
    case SolidarityGuideKeyHousing = 2
    case SolidarityGuideKeyHeal = 3
    case SolidarityGuideKeyRefresh = 4
    case SolidarityGuideKeyOrientation = 5
    case SolidarityGuideKeyCaring = 6
    case SolidarityGuideKeyReinsertion = 7
    case SolidarityGuideKeyPartners = 8
    case none = -1
}

protocol OTSolidarityGuideFilterDelegate2: NSObject {
    func getSolidarityFilter() -> OTSolidarityGuideFilter2
    func solidarityFilterChanged(_ filter: OTSolidarityGuideFilter2!)
}
