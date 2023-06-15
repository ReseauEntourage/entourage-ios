//
//  WelcomeTwoViewController.swift
//  entourage
//
//  Created by Clement entourage on 30/05/2023.
//

import Foundation
import UIKit

enum WelcomeTwoDTO{
    case describingcell
    case groupCellExample
    case emptycell
}

protocol WelcomeTwoDelegate{
    func goMyGroup(id:Int,group:Neighborhood)
    func goGroupList()
}

class WelcmeTwoViewController:UIViewController{
    
    @IBOutlet weak var ui_table_view: UITableView!
    
    @IBOutlet weak var ui_button_close: UIImageView!
    
    
    var isGroupSuppressed = false
    var tableDTO = [WelcomeTwoDTO]()
    var hashedNeighborhoodId = "default"
    var titleGroup = "Un réseau social, c'est mieux à plusieurs ! Présentez-vous auprès de votre groupe  voisins de Paris."
    var groupdId = 0
    var myGroup:Neighborhood? = nil
    var delegate:WelcomeTwoDelegate?
    
    override func viewDidLoad() {
        ui_table_view.backgroundColor = UIColor(named: "orange_tres_tres_clair")
        fillTableDTO()
        initButton()
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        ui_table_view.register(UINib(nibName: WelcomeTwoDescribingCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeTwoDescribingCell.identifier)
        ui_table_view.register(UINib(nibName: WelcomeTwoGroupExampleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeTwoGroupExampleCell.identifier)
        ui_table_view.reloadData()
        
        AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNeighborhoodDetail()
    }
    
    func fillTableDTO(){
        tableDTO.append(.describingcell)
        tableDTO.append(.groupCellExample)
    }
    
    func initButton(){
        ui_button_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        ui_button_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionGoVoisin(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day2)
        self.dismiss(animated: true) { [self] in
            if self.isGroupSuppressed {
                self.delegate?.goGroupList()
            }else{
                delegate?.goMyGroup(id: self.groupdId,group:self.myGroup!)
            }
        }
    }
    
    func getNeighborhoodDetail(hasToRefreshLists:Bool = false) {

        var _groupId = ""
         if hashedNeighborhoodId != "" {
            _groupId = hashedNeighborhoodId
        }
        
        NeighborhoodService.getNeighborhoodDetail(id: _groupId) { group, error in
            
            if group == nil {
                self.isGroupSuppressed = true
            }else{
                self.groupdId = group!.uid
                self.myGroup = group!
                if group!.name.contains("groupe") || group!.name.contains("Groupe"){
                    self.titleGroup = "Un réseau social, c'est mieux à plusieurs ! Présentez-vous auprès de votre " + group!.name
                }else{
                    self.titleGroup = "Un réseau social, c'est mieux à plusieurs ! Présentez-vous auprès de votre groupe " + group!.name
                }
            }
            
            //self.neighborhood = group
            self.ui_table_view.reloadData()
            
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationNeighborhoodsUpdate), object: nil)
            }
        }
    }
    
    
    
    
}

extension WelcmeTwoViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
        case .describingcell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeTwoDescribingCell", for: indexPath) as! WelcomeTwoDescribingCell
            cell.selectionStyle = .none
            cell.configure(title: self.titleGroup)
            return cell
        case .groupCellExample:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeTwoGroupExampleCell", for: indexPath) as! WelcomeTwoGroupExampleCell
            cell.selectionStyle = .none
            return cell
        case .emptycell:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "orange_tres_tres_clair")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
            
        case .describingcell:
            return UITableView.automaticDimension
        case .groupCellExample:
            return UITableView.automaticDimension
        case .emptycell:
            return 50
        }
        
    }
}
