//
//  ActionCreatePhase4ViewController.swift
//  entourage
//
//  Created by Clement entourage on 28/10/2024.
//

import Foundation
import UIKit

enum Action4CreateDTO {
    case header
    case choice
}

class ActionCreatePhase4ViewController:UIViewController {
    
    //OUTLET
    @IBOutlet weak var ui_tableview: UITableView!
    
    //VARIABLE
    var tableDTO = [Action4CreateDTO]()
    var cityName = ""
    var isContrib = false
    weak var pageDelegate:ActionCreateMainDelegate? = nil

    override func viewDidLoad() {
        ui_tableview.register(UINib(nibName: CreateAction4HeaderCell.identifier, bundle: nil), forCellReuseIdentifier: CreateAction4HeaderCell.identifier)
        ui_tableview.register(UINib(nibName: CreateAction4ChoiceCell.identifier, bundle: nil), forCellReuseIdentifier: CreateAction4ChoiceCell.identifier)
        self.ui_tableview.delegate = self
        self.ui_tableview.dataSource = self
        searchForDefaultGroupName()
    }
    
    func searchForDefaultGroupName(){
        NeighborhoodService.getDefaultGroup { group, error in
            if let _group = group {
                self.cityName = _group.name
            }
            self.initDTO()
        }
    }
    
    func initDTO(){
        self.tableDTO.removeAll()
        self.tableDTO.append(.header)
        self.tableDTO.append(.choice)
        self.ui_tableview.reloadData()
    }
    
    
}

extension ActionCreatePhase4ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
            
        case .header:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "CreateAction4HeaderCell") as? CreateAction4HeaderCell {
                cell.selectionStyle = .none
                var actionType = ""
                if isContrib {
                    actionType = "contribution"
                }else{
                    actionType = "demande"
                }
                cell.configure(cityGroup: cityName, actionType: actionType)
                return cell
            }
        case .choice:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "CreateAction4ChoiceCell") as? CreateAction4ChoiceCell {
                cell.selectionStyle = .none
                cell.configure()
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ActionCreatePhase4ViewController:CreateAction4ChoiceCellDelegate{
    func didUpdateShareToGroup(_ shareToGroup: Bool?) {
        pageDelegate?.setShareToGroup(shareToGroup: shareToGroup ?? false)

    }
    
}
