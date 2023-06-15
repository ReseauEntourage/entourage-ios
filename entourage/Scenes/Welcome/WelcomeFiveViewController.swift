//
//  WelcomeFiveViewController.swift
//  entourage
//
//  Created by Clement entourage on 15/06/2023.
//

import Foundation
import UIKit

enum WelcomeFiveDTO{
    case titleCell
    case mainTextCell
    case emptyCell
}


class WelcomeFiveViewController:UIViewController{
    
    @IBOutlet weak var ui_table_view: UITableView!
    
    @IBOutlet weak var ic_btn_close: UIImageView!
    @IBOutlet weak var ic_button: UIButton!
    
    var tableDTO = [WelcomeFiveDTO]()
    
    override func viewDidLoad() {
        AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day11)
        initTableView()
        registerCells()
        initButton()
        loadDTO()
        
    }
    
    func initTableView(){
        ui_table_view.delegate = self
        ui_table_view.dataSource = self
        
    }
    
    func loadDTO(){
        tableDTO.append(.titleCell)
        tableDTO.append(.mainTextCell)
        tableDTO.append(.emptyCell)
        self.ui_table_view.reloadData()
    }
    
    private func registerCells(){
        ui_table_view.register(UINib(nibName: WelcomeOneContentMain.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneContentMain.identifier)
        ui_table_view.register(UINib(nibName: WelcomeOneTitleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneTitleCell.identifier)
    }
    
    
    func initButton(){
        ic_button.setTitle("welcome_five_main_button_title".localized, for: .normal)
        ic_button.addTarget(self, action: #selector(mainTapped), for: .touchUpInside)
        ic_btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        ic_btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func mainTapped() {
        AnalyticsLoggerManager.logEvent(name: Action_WelcomeOfferHelp_Day11)
        self.dismiss(animated: true) {
            let activityViewController = UIActivityViewController(activityItems: ["https://apps.apple.com/app/id1072244410"], applicationActivities: nil)
            AppState.getTopViewController()!.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}


extension WelcomeFiveViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
            
        case .titleCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            cell.initForWelcomeFive()
            cell.selectionStyle = .none
            return cell
        case .mainTextCell:
            let cell = self.ui_table_view.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            cell.initForWelcomeFive()
            cell.selectionStyle = .none
            return cell
        case .emptyCell:
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "orange_tres_tres_clair")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
        case .titleCell:
            return UITableView.automaticDimension
        case .mainTextCell:
            return UITableView.automaticDimension
        case .emptyCell:
            return 70
        }
    }
    
}
