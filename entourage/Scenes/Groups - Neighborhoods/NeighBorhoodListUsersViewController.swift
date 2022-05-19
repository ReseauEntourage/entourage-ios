//
//  NeighBorhoodListUsersViewController.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//

import UIKit

class NeighBorhoodListUsersViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!
    
    var neighborhood:Neighborhood? = nil
    
    var users = [UserLightNeighborhood]()
    var usersSearch = [UserLightNeighborhood]()
    var isAlreadyClearRows = false
    var isSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.populateView(title: "neighborhood_users_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = "neighborhood_group_search_empty_title".localized
        ui_view_no_result.isHidden = true
        getusers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    
    func getusers() {
        guard let neighborhood = neighborhood else {
            return
        }
        
        NeighborhoodService.getNeighborhoodUsers(neighborhoodId: neighborhood.uid, completion: { users, error in
            if let _ = error {
                self.goBack()
            }
            if let users = users {
                self.users = users
            }
            self.ui_tableview.reloadData()
        })
    }
    
    func searchUser(text:String) {
        //TODO: find user
        usersSearch.removeAll()
        let _searched = users.filter({$0.displayName.lowercased().contains(text.lowercased())})
        usersSearch.append(contentsOf: _searched)
        if usersSearch.count == 0 {
            ui_view_no_result.isHidden = false
        }
        else {
            ui_view_no_result.isHidden = true
        }
        self.ui_tableview.reloadData()
    }
}

//MARK: - Tableview Datasource/delegate -
extension NeighBorhoodListUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return usersSearch.count + 1
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            
            cell.populateCell(delegate: self, isSearch:isSearch,placeceholder:"neighborhood_userInput_search".localized)
            return cell
        }
        
        var user:UserLightNeighborhood
        let position = indexPath.row - 1
        
        if isSearch {
            user = self.usersSearch[position]
        }
        else {
            user = self.users[position]
        }
        
        let isMe = user.sid == UserDefaults.currentUser?.sid
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! NeighborhoodUserCell
        
        cell.populateCell(isMe:isMe, username: user.displayName, role: user.getCommunityRolesFormated(), imageUrl: user.avatarURL, showBtMessage: true,delegate: self,position: position)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        
        var user:UserLightNeighborhood
        if isSearch {
            user = self.usersSearch[indexPath.row - 1]
        }
        else {
            user = self.users[indexPath.row - 1]
        }
        
        if let navVC = UIStoryboard.init(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(user.sid)"
                
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
}

//MARK: - NeighborhoodHomeSearchDelegate  -
extension NeighBorhoodListUsersViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            self.searchUser(text: text)
        }
        else {
            self.usersSearch.removeAll()
            self.isAlreadyClearRows = false
            self.isSearch = false
            ui_view_no_result.isHidden = true
            self.ui_tableview.reloadData()
        }
    }
    
    func showEmptySearch() {
        isSearch = true
        if !isAlreadyClearRows {
            isAlreadyClearRows = true
            self.ui_tableview.reloadData()
        }
        else {
            isAlreadyClearRows = false
        }
        ui_view_no_result.isHidden = true
    }
}

//MARK: - NeighborhoodUserCellDelegate -
extension NeighBorhoodListUsersViewController:NeighborhoodUserCellDelegate {
    func showUserForPosition(_ position: Int) {
        //TODO: a faire
        Logger.print("***** show message from user pos : \(position)")
        
        showWIP(parentVC: self.navigationController)
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighBorhoodListUsersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
