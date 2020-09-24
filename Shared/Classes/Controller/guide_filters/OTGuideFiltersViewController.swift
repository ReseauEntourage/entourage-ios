//
//  OTGuideFiltersViewController.swift
//  entourage
//
//  Created by Jr on 17/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTGuideFiltersViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    weak var filterDelegate:OTGuideFilterDelegate? = nil
    
    var filters = OTGuideFilters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _delegate = filterDelegate {
            filters = _delegate.getSolidarityFilter()
        }
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "filters")?.uppercased()
        
        self.setupCloseModal(withTarget: self, andSelector: #selector(close))
        OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
        
        let menuButton = UIBarButtonItem(title: OTLocalisationService.getLocalizedValue(forKey: "save")?.capitalized, style: .done, target: self , action: #selector(saveFilters))
        
        self.navigationItem.setRightBarButton(menuButton, animated: false)
        
        self.ui_tableview.tableFooterView = UIView(frame: .zero)
    }
    
    //MARK: - Actions from bar Buttons
    @objc func close() {
        OTLogger.logEvent("CloseFilter")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveFilters() {
        OTLogger.logEvent("SubmitFilterPreferences")
        var currentFilter = self.filters
        
        for i in currentFilter.arrayFilters.indices {
            currentFilter.updateValueFilter(position: i)
        }
        
        dismiss(animated: true) {
            self.filterDelegate?.solidarityFilterChanged(currentFilter)
        }
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
        
        return filters.arrayFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FiltersTopCell", for: indexPath) as! OTGuideTopFilterCell
            cell.populateCell(isPartnerOn: self.filters.showPartners, isDonatedOn: self.filters.showDonated, isVolunteerOn: self.filters.showVolunteer, delegate: self)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFilterCell", for: indexPath) as! OTGuideFilterCell
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
    
    //MARK: - ChangeFilterGDSDelegate - 
    func changeAtPosition(_ position: Int, isActive: Bool) {
        self.filters.arrayFilters[position].active = isActive
    }
    
    func changeTop(_ position:Int,isActive:Bool) {
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
