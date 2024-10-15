//
//  ActionCreatePhase2ViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit

class ActionCreatePhase2ViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    
    weak var pageDelegate:ActionCreateMainDelegate? = nil
    
    var tagsSections:Sections! = nil
    
    var currentAction:Action? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ui_lbl_info.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        let _msg = String.init(format: "action_create_title_category".localized, pageDelegate?.isContribution() ?? false ? "action_contrib".localized : "action_solicitation".localized)
        
        let stringAttr = Utils.formatString(messageTxt: _msg, messageTxtHighlight: "action_create_title_category_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_lbl_info.attributedText = stringAttr
        
        NotificationCenter.default.addObserver(self, selector: #selector(showError), name: NSNotification.Name(kNotificationEventCreatePhase4Error), object: nil)
        ui_error_view.isHidden = true
        self.ui_error_view.setupView(title: "actionCreatePhase2_error".localized)
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        tagsSections = Metadatas.sharedInstance.tagsSections
        
        if pageDelegate?.isEdit() ?? false {
            currentAction = pageDelegate?.getCurrentAction()
            
            if let _sectionName = currentAction?.sectionName {
                tagsSections.getSectionFrom(key: _sectionName)?.isSelected = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tagsInterests = tagsSections, tagsInterests.getSections().count > 0 else {
            self.dismiss(animated: true)
            return
        }
        ui_error_view.isHidden = true
        super.viewWillAppear(animated)
    }
    
    @objc func showError(notification:Notification) {
        if let message = notification.userInfo?["error_message"] as? String {
            ui_error_view.setupView(title: message, imageName: nil)
            ui_error_view.isHidden = false
        }
        else {
            ui_error_view.isHidden = true
        }
    }
}

//MARK: - Tableview Datasource/delegate -
extension ActionCreatePhase2ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tagsSections?.getSections().count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tagsSections.getSections().count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfos", for: indexPath) as! ActionTagInfoCell
            
            let title = pageDelegate?.isContribution() ?? false ? "action_create_info_contrib".localized : "action_create_info_demand".localized
            let titleUnderline = pageDelegate?.isContribution() ?? false ? "action_create_info_contrib_underline".localized : "action_create_info_demand_underline".localized
            
            cell.populateCell(title: title, titleColored: titleUnderline, color:.black,colored:.appOrange, font: ApplicationTheme.getFontNunitoLight(size: 13) )
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInterest", for: indexPath) as! SelectTagCell
        
        let section = tagsSections?.getSections()[indexPath.row]
        
        cell.populateCell(title: section?.key ?? "-" , isChecked: section!.isSelected, imageName: section?.getImageName(), subtitle: section?.key, isSingleSelection: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == tagsSections.getSections().count {
            //TODO: link
            showWIP(parentVC: self)
            return
        }
        
        let selectedSection = tagsSections.getSections()[indexPath.row]
        tagsSections.setSectionSelected(key:selectedSection.key )
        ActionCreateStateManager.shared.storeSection(selectedSection.key, isContrib: pageDelegate?.isContribution() ?? false)
        self.pageDelegate?.addInterest(section: selectedSection)
        self.ui_tableview.reloadData()
    }
}
