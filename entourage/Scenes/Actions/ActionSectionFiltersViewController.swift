//
//  ActionSectionFiltersViewController.swift
//  entourage
//
//  Created by Jerome on 11/08/2022.
//

import UIKit

class ActionSectionFiltersViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    weak var delegate:EventSectionFiltersDelegate? = nil
    
    var sectionFilters:Sections! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = sectionFilters else {
            self.goBack()
            return
        }
        
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        ui_top_view.populateView(title: "action_filter_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
    }
    
    //MARK: - IBAction -
    @IBAction func action_validate(_ sender: Any) {
        delegate?.updateSectionFilters(sectionFilters!)
        self.goBack()
    }

}

//MARK: - Tableview datasource/delegate -
extension ActionSectionFiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionFilters != nil ? sectionFilters!.getSections().count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == sectionFilters!.getSections().count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellValidate", for: indexPath)
            return cell
        }
        
        let section = sectionFilters!.getSections()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! SelectTagCell
        
        cell.populateCell(title: section.name, isChecked: section.isSelected, imageName: section.getImageName(), hideSeparator: false, subtitle: section.subtitle, isSingleSelection: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == sectionFilters.getSections().count {
            return
        }
        sectionFilters!.getSections()[indexPath.row].isSelected = !sectionFilters!.getSections()[indexPath.row].isSelected
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

//MARK: - MJNavBackViewDelegate -
extension ActionSectionFiltersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - Protocol Event Filter
protocol EventSectionFiltersDelegate:AnyObject {
    func updateSectionFilters(_ filters:Sections)
}
