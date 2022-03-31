//
//  MainUserProfileViewController.swift
//  entourage
//
//  Created by Jerome on 08/03/2022.
//

import UIKit

class MainUserProfileViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView?
    
    var currentUser:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = UserDefaults.currentUser
        
        ui_tableview?.dataSource = self
        ui_tableview?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadDatas()
    }
    
    private func reloadDatas() {
        ui_tableview?.reloadData()
    }
    
    func updateUser() {
        currentUser = UserDefaults.currentUser
        reloadDatas()
    }
    
    func updateVC() {
        loadUser()
    }
    
    private func loadUser() {
        guard let uuid = currentUser?.uuid  else { return }
        
        UserService.getDetailsForUser(userId: uuid) { [weak self] user, error in
            if let _user = user {
                self?.currentUser = _user
                UserDefaults.currentUser = _user
                DispatchQueue.main.async {
                    self?.updateUser()
                }
            }
        }
    }
}

//MARK: - Tableview datasource / delegate -
extension MainUserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfoTop", for: indexPath) as! MainUserProfileTopCell
            cell.populateCell(username: currentUser.displayName, role: currentUser.roles?.first, partner: currentUser.partner, bio: currentUser.about,delegate: self)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfoCats", for: indexPath) as! CategoriesBubblesCell
            cell.populateCell(interests: currentUser.interests)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfoActivities", for: indexPath) as! MainUserActivitiesCell
            cell.populateCell(eventCount: currentUser.stats.eventsCount, actionsCount: currentUser.stats.actionsCount)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserInfos", for: indexPath) as! MainUserInfosCell
            cell.populateCell(user: currentUser)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //To fix heigh categories view if empty
        if indexPath.row == 1 && currentUser.interests?.count ?? 0 == 0 {
            return 0
        }
        return UITableView.automaticDimension
    }
}

//MARK: - MainUserProfileTopCellDelegate -
extension MainUserProfileViewController: MainUserProfileTopCellDelegate {
    func showPartner() {
        if let navVc = UIStoryboard.init(name: "PartnerDetails", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            if let vc = navVc.topViewController as? PartnerDetailViewController {
                if let id = currentUser.partner?.aid {
                    vc.partnerId = id
                }
                else {
                    vc.partner = currentUser.partner
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.present(navVc, animated: true)
                }
            }
        }
    }
    func sendMessage() {}
}
