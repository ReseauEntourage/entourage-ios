//
//  ActionsMyListViewController.swift
//  entourage
//
//  Created by Jerome on 04/08/2022.
//

import UIKit
import IHProgressHUD

class ActionsMyListViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_lb_no_result_subtitle: UILabel!
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!
    
    var actions = [Action]()
    
    var isLoading = false
    var currentPage = 1
    let numberOfItemsForWS = 25 // Arbitrary nb of items used for pagging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the end of the list to send new call
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "actions_my_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
        
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lb_no_result.text = "Vous n’avez publié aucune annonce"
        ui_lb_no_result_subtitle.text = "Vous pouvez créer une contribution ou une demande en cliquant sur le « + » de la page « Entraide »"
        ui_view_no_result.isHidden = true
        
        getMyActions()
        //Notif for updating action infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateAction), name: NSNotification.Name(rawValue: kNotificationActionUpdate), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateAction() {
        currentPage = 1
        
        getMyActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
        getMyActions()
    }
    
    func getMyActions() {
        if self.isLoading { return }
        IHProgressHUD.show()
        self.isLoading = true
        ActionsService.getAllMyActions(currentPage: currentPage, per: numberOfItemsForWS) { actions, error in
           
            IHProgressHUD.dismiss()
            self.isLoading = false
            
            if let actions = actions {
                if self.currentPage > 1 {
                    self.actions.append(contentsOf: actions)
                }
                else {
                    self.actions = actions
                }
                
                self.ui_tableview.reloadData()
                if self.actions.count > 0 && self.currentPage == 1 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    DispatchQueue.main.async {
                        self.ui_tableview?.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
            if self.actions.count == 0 {
                self.ui_view_no_result.isHidden = false
            }
            else {
                self.ui_view_no_result.isHidden = true
            }
        }
    }
}

//MARK: - Tableview Datasource/delegate -
extension ActionsMyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let action = actions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMy", for: indexPath) as! ActionMineCell
        cell.populateCell(action: action)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        if let navvc = storyboard?.instantiateViewController(withIdentifier: "actionDetailFullNav") as? UINavigationController, let vc = navvc.topViewController as? ActionDetailFullViewController {
            vc.actionId = action.id
            vc.action = action
            vc.isContrib = action.isContrib()
            vc.parentVC = self.navigationController
            self.navigationController?.present(navvc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        
        let lastIndex = actions.count - nbOfItemsBeforePagingReload
        
        if indexPath.row == lastIndex && self.actions.count >= numberOfItemsForWS * currentPage {
            self.currentPage = self.currentPage + 1
            self.getMyActions()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension ActionsMyListViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
