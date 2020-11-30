//
//  OTGuideFiltersViewController.swift
//  entourage
//
//  Created by Jr on 17/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTGuideFiltersViewController: UIViewController, ClosePopDelegate {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    weak var filterDelegate:OTGuideFilterDelegate? = nil
    
    var filters = OTGuideFilters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_validate.layer.cornerRadius = 5
        
        if let _delegate = filterDelegate {
            filters = _delegate.getSolidarityFilter()
        }
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "filters")?.uppercased()
        
        addCloseButtonLeftWithWhiteColorBar()
        
        let resetButton = UIBarButtonItem(title: OTLocalisationService.getLocalizedValue(forKey: "button_reset_filters"), style: .plain, target: self, action: #selector(resetFilters))
        
        self.navigationItem.setRightBarButton(resetButton, animated: false)
        resetButton.tintColor = UIColor.appOrange()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.appOrange()
        resetButton.setTitleTextAttributes([.foregroundColor: resetButton.tintColor as Any], for: .normal)
        
        self.ui_tableview.tableFooterView = UIView(frame: .zero)
        
        checkFilters()
    }
    
    func checkFilters() {
        if filters.isDefaultFiltersNew() {
            ui_bt_validate.setTitle(OTLocalisationService.getLocalizedValue(forKey: "showAll"), for: .normal)
        }
        else {
            ui_bt_validate.setTitle(OTLocalisationService.getLocalizedValue(forKey: "validate"), for: .normal)
        }
    }
    
    @IBAction func action_validate_filters(_ sender: Any) {
        OTLogger.logEvent(Action_guideMap_SubmitFilters)
        var currentFilter = self.filters
        
        for i in currentFilter.arrayFilters.indices {
            currentFilter.updateValueFilter(position: i)
        }
        
        dismiss(animated: true) {
            self.filterDelegate?.solidarityFilterChanged(currentFilter)
        }
    }
    //MARK: - Actions from bar Buttons
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveFilters() {
        OTLogger.logEvent(Action_guideMap_SubmitFilters)
        var currentFilter = self.filters
        
        for i in currentFilter.arrayFilters.indices {
            currentFilter.updateValueFilter(position: i)
        }
        
        dismiss(animated: true) {
            self.filterDelegate?.solidarityFilterChanged(currentFilter)
        }
    }
    
    @objc func resetFilters() {
        self.filters.setAllFiltersOn()
        checkFilters()
        self.ui_tableview.reloadData()
    }
}

//MARK: - Tableview Datasource / Delegate
extension OTGuideFiltersViewController: UITableViewDelegate,UITableViewDataSource, ChangeFilterGDSDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        self.checkFilters()
        return filters.arrayFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersTopCell", for: indexPath) as! OTGuideTopFilterCell
            let isAllActive = filters.isDefaultFiltersNew()
            cell.populateCell(isPartnerOn: self.filters.showPartners, isDonatedOn: self.filters.showDonated, isVolunteerOn: self.filters.showVolunteer, delegate: self,isAllActive: isAllActive)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFilterCell", for: indexPath) as! OTGuideFilterCell
        let isAllActive = filters.isDefaultFiltersNew()
        cell.populateCell(item: filters.arrayFilters[indexPath.row],position: indexPath.row, isAllActive: isAllActive)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let isActive = self.filters.arrayFilters[indexPath.row].active
            
            if isActive && !filters.isDefaultFiltersNew() {
                self.filters.setAllFiltersOn()
            }
            else {
                self.filters.setAllFiltersOff(position: indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - ChangeFilterGDSDelegate - 
    func changeAtPosition(_ position: Int, isActive: Bool) {
        self.filters.arrayFilters[position].active = isActive
    }
    
    func changeTop(_ position:Int) {
        switch position {
        case 1:
            OTLogger.logEvent(Action_guide_searchFilter_organiz)
            if self.filters.showPartners && !filters.isDefaultFiltersNew() {
                self.filters.setAllFiltersOn()
            }
            else {
                self.filters.setAllFiltersOff(position: -1)
            }
        case 2:
            OTLogger.logEvent(Action_guide_searchFilter_Donat)
            if self.filters.showDonated && !filters.isDefaultFiltersNew() {
                self.filters.setAllFiltersOn()
            }
            else {
                self.filters.setAllFiltersOff(position: -2)
            }
        case 3:
            OTLogger.logEvent(Action_guide_searchFilter_Volunt)
            if self.filters.showVolunteer && !filters.isDefaultFiltersNew()  {
                self.filters.setAllFiltersOn()
            }
            else {
                self.filters.setAllFiltersOff(position: -3)
            }
        default:
            break
        }
        self.ui_tableview.reloadData()
    }
}
