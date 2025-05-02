//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit

class EventCreatePhase5ViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_info: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    
    weak var pageDelegate:EventCreateMainDelegate? = nil
    
    var groups = [Neighborhood]()
    
    var isSharing = false
    
    var currentEvent:Event? = nil
    
    var currentNeighborhoodId:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let stringAttr = Utils.formatString(messageTxt: "event_create_phase5_title".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        
        ui_lbl_info.attributedText = stringAttr
        
        ui_error_view.isHidden = true
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showError), name: NSNotification.Name(kNotificationEventCreatePhase5Error), object: nil)
        
        currentNeighborhoodId = pageDelegate?.getNeighborhoodId()
        
        if pageDelegate?.isEdit() ?? false {
            currentEvent = pageDelegate?.getCurrentEvent()
            if currentEvent?.neighborhoods?.count ?? 0 > 0 {
                isSharing = true
            }
        }
        getMyGroups()
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
    
    func getMyGroups() {
        guard let me = UserDefaults.currentUser else {return}
        NeighborhoodService.getNeighborhoodsForUserId("\(me.sid)", currentPage: 1, per: 100) { groups, error in
            if let groups = groups {
                self.groups = groups
                
                if let _groups = self.currentEvent?.neighborhoods {
                    for _group in _groups {
                        var  i = 0
                        for groupNew in self.groups {
                            if groupNew.uid == _group.id {
                                self.groups[i].isSelected = true
                                break
                            }
                            i = i + 1
                        }
                    }
                }
                else if let currentNeighborhoodId = self.currentNeighborhoodId {
                    self.isSharing = true
                    var i = 0
                    for groupNew in self.groups {
                        if groupNew.uid == currentNeighborhoodId {
                            self.groups[i].isSelected = true
                            break
                        }
                        i = i + 1
                    }
                    self.updateNeighborhoodSelection()
                }
                
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
        }
    }
    
    func updateNeighborhoodSelection() {
        var groupsId = [EventNeighborhood]()
        groups.forEach { group in
            if group.isSelected {
                groupsId.append(EventNeighborhood(id: group.uid, name: "-"))
            }
        }
        if groupsId.count > 0 {
            ui_error_view.isHidden = true
            pageDelegate?.addShare(isSharing)
        }
        
        pageDelegate?.addShareGroups(groups: groupsId)
    }
}
//MARK: - UITableView datasource / Delegate -
extension EventCreatePhase5ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  isSharing ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1}
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! EventShareCell
            
            cell.populateCell(isSharing: isSharing, delegate: self)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroup", for: indexPath) as! SelectTagCell
        
        let group = groups[indexPath.row]
        cell.populateCell(title: group.name, isChecked: group.isSelected, isAction: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        groups[indexPath.row].isSelected = !groups[indexPath.row].isSelected
        
        updateNeighborhoodSelection()
        
        tableView.reloadData()
    }
}
//MARK: - EventShareCellDelegate -
extension EventCreatePhase5ViewController: EventShareCellDelegate {
    func setSharing(_ isSharing: Bool) {
        Logger.print("***** Is sharing : \(isSharing)")
        self.isSharing = isSharing
        self.ui_error_view.isHidden = true
        
        groups.indices.forEach {
            groups[$0].isSelected = false
        }
        pageDelegate?.addShare(isSharing)
        pageDelegate?.addShareGroups(groups: nil)
        
        self.ui_tableview.reloadData()
    }
}
