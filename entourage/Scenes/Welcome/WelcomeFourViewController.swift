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
     
}

class WelcomeFourViewController:UIViewController {
    
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var ui_main_button: UIButton!
    @IBOutlet weak var ui_btn_close: UIImageView!
    
    var tableDTO = [WelcomeFourDTO]()
    
    override func viewDidLoad() {
        initButton()
        initTableView()
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
        ui_main_button.titleLabel?.text = "welcome_four_main_button_title".localized
        ui_main_button.addTarget(self, action: #selector(mainTapped), for: .touchUpInside)
        ui_btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        ui_btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func mainTapped() {
        
    }
    
}

extension WelcomeFourViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(tableDTO[indexPath.row]){
            
        case .titleCell:
            return UITableViewCell()
        case .mainTextCell:
            return UITableViewCell()
        case .secondTextCell:
            return UITableViewCell()
        case .imageCell:
            return UITableViewCell()
        }
    }
    
    
}
