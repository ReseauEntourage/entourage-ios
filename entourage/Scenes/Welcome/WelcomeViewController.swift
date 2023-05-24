//
//  WelcomeViewController.swift
//  entourage
//
//  Created by Clement entourage on 17/05/2023.
//

import Foundation
import WebKit

enum WelcomeOneDTO {
    case titleWelcome
    case contentMain
    case youtubecontainer
    case contentbottom
}

protocol WelcomeOneDelegate {
    func onClickedLink()
}


class WelcomeViewController:UIViewController {
    //OUTLET VAR
    @IBOutlet weak var ui_imagebtn_back: UIImageView!
    
    @IBOutlet weak var btn_close: UIImageView!
    @IBOutlet weak var ui_tableview: UITableView!
    
    // MACHINE VAR
    var tableDTO = [WelcomeOneDTO]()
    var delegate:WelcomeOneDelegate?
    
    override func viewDidLoad() {
        loadDTO()
        initButton()
        AnalyticsLoggerManager.logEvent(name: View_WelcomeOfferHelp_Day1)
        //DELEGATE AND DATASOURCE
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        //REGISTER CELLS
        ui_tableview.register(UINib(nibName: WelcomeOneTitleCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneTitleCell.identifier)
        ui_tableview.register(UINib(nibName: WelcomeOneContentLast.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneContentLast.identifier)
        ui_tableview.register(UINib(nibName: WelcomeOneWebViewCell.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneWebViewCell.identifier)
        ui_tableview.register(UINib(nibName: WelcomeOneContentMain.identifier, bundle: nil), forCellReuseIdentifier: WelcomeOneContentMain.identifier)
        
        //REINIT
        
        self.ui_tableview.reloadData()
    }
    
    func initButton(){
         btn_close.isUserInteractionEnabled = true
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
         btn_close.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // CHOOSE CELLS TO DISPLAY
    func loadDTO(){
        tableDTO.append(.titleWelcome)
        tableDTO.append(.contentMain)
        tableDTO.append(.youtubecontainer)
        tableDTO.append(.contentbottom)
    }
    
}

extension WelcomeViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
        case .titleWelcome:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "WelcomeOneTitleCell", for: indexPath) as! WelcomeOneTitleCell
            return cell
        case .contentMain:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "WelcomeOneContentMain", for: indexPath) as! WelcomeOneContentMain
            return cell
        case .youtubecontainer:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "WelcomeOneWebViewCell", for: indexPath) as! WelcomeOneWebViewCell
            return cell
        case .contentbottom:
            let cell = self.ui_tableview.dequeueReusableCell(withIdentifier: "WelcomeOneContentLast", for: indexPath) as! WelcomeOneContentLast
            cell.delegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableDTO[indexPath.row]{
        case .titleWelcome:
            return UITableView.automaticDimension
        case .contentMain:
            return UITableView.automaticDimension
        case .youtubecontainer:
            return 200
        case .contentbottom:
            return UITableView.automaticDimension
        }
    }
}

extension WelcomeViewController:WelcomeOneLastCellDelegate{
    func onLinkClicked() {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.onClickedLink()
    }
}


