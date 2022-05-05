//
//  NeighborhoodParamsGroupViewController.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodParamsGroupViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var isCreator = false
    var neighborhood:Neighborhood? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserId = UserDefaults.currentUser?.sid
        if neighborhood?.creator.uid == currentUserId {
            isCreator = true
        }
        else {
            isCreator = false
        }
        
        ui_top_view.populateView(title: "neighborhood_params_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood(_ :)), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = neighborhood else {
            self.goBack()
            return
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    @objc func updateNeighborhood(_ notification:Notification) {
        if let neighB = notification.userInfo?["neighborhood"] as? Neighborhood {
            self.neighborhood = neighB
            self.ui_tableview.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Tableview Datasource/delegate -
extension NeighborhoodParamsGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCreator ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_info", for: indexPath) as! NeighborhoodParamTopCell
            
            cell.populateCell(neighborhood: neighborhood)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
            cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group")
            
            return cell
        case 2:
            if isCreator {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                
                cell.populateCell(title: "neighborhood_params_edit".localized,imageName: "ic_edit_group")
                
                return cell
            }
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            if let  vc = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? NeighBorhoodParamsCGUViewController {
                vc.modalPresentationStyle = .fullScreen
                
                self.navigationController?.present(vc, animated: true)
            }
            return
        case 2:
            if isCreator {
                if let  vc = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "editGroupVC") as? NeighborhoodEditViewController {
                    vc.modalPresentationStyle = .fullScreen
                    vc.currentNeighborhoodId = self.neighborhood!.uid
                    
                    self.navigationController?.present(vc, animated: true)
                }
                return
            }
        case 3:
            break
        default:
            return
        }
        
        if let  vc = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.modalPresentationStyle = .currentContext
            vc.group = neighborhood
            vc.parentDelegate = self
            vc.signalType = .group
            self.navigationController?.present(vc, animated: true)
        }
    }
}

//MARK: - GroupDetailDelegate -
extension NeighborhoodParamsGroupViewController: GroupDetailDelegate {
    func showMessage(message: String, imageName: String?) {
        //TODO: on affiche cette info ou une pop custom ?
        IHProgressHUD.showSuccesswithStatus(message)
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodParamsGroupViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
