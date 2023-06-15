//
//  WelcomeFourViewController.swift
//  entourage
//
//  Created by Clement entourage on 14/06/2023.
//

import Foundation
import UIKit

enum WelcomeFourDTO{
    case titleCell
    case mainTextCell
    case secondTextCell
    case imageCell
    case blanckCell
     
}

class WelcomeFourViewController:UIViewController {
    
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_main_button: UIButton!
    @IBOutlet weak var ui_btn_close: UIImageView!
    
    var tableDTO = [WelcomeFourDTO]()
    
    override func viewDidLoad() {
        ui_table_view.backgroundColor = UIColor(named: "orange_tres_tres_clair")
        initButton()
        initTableView()
        registerCells()
        loadDTO()
    }
    
    func initTableView(){
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        
    }
    
    private func registerCells(){
        ui_table_view.register(UINib(nibName: WelcomeOneContentMain.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneContentMain.identifier)
        ui_table_view.register(UINib(nibName: WelcomeOneTitleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneTitleCell.identifier)
        ui_table_view.register(UINib(nibName: SecondaryTextWelcomeCell.identifier, bundle: nil), forCellReuseIdentifier: SecondaryTextWelcomeCell.identifier)
        ui_table_view.register(UINib(nibName: WelcomeFourImageCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeFourImageCell.identifier)
        //Imagecell register

    }
    
    func loadDTO(){
        tableDTO.append(.titleCell)
        tableDTO.append(.mainTextCell)
        tableDTO.append(.secondTextCell)
        tableDTO.append(.imageCell)
    }
    
    func initButton(){
        ui_main_button.setTitle("welcome_four_main_button_title".localized, for: .normal)
        ui_main_button.addTarget(self, action: #selector(mainTapped), for: .touchUpInside)
        ui_btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        ui_btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func mainTapped() {
        self.dismiss(animated: true) {
            if let _url = URL(string: "/https://kahoot.it/challenge/45371e80-fe50-4be5-afec-b37e3d50ede2_1683299255475"){
                WebLinkManager.openUrl(url: _url, openInApp: true, presenterViewController: AppState.getTopViewController())
            }
        }
    }
    
}

extension WelcomeFourViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(tableDTO[indexPath.row]){
            
        case .titleCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            cell.initForWelcomeFour()
            cell.selectionStyle = .none
            return cell
        case .mainTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            cell.initForWelcomeFour()
            cell.selectionStyle = .none
            return cell
        case .secondTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "SecondaryTextWelcomeCell", for: indexPath) as! SecondaryTextWelcomeCell
            cell.initForWelcomeFour()
            cell.selectionStyle = .none
            return cell
        case .imageCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeFourImageCell", for: indexPath) as! WelcomeFourImageCell
            cell.selectionStyle = .none
            return cell
        case .blanckCell:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "orange_tres_tres_clair")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
