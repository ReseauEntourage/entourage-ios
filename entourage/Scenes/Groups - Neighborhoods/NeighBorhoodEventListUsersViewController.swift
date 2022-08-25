//
//  NeighBorhoodListUsersViewController.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//

import UIKit
import IHProgressHUD

class NeighBorhoodEventListUsersViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!
    
    var neighborhood:Neighborhood? = nil
    var event:Event? = nil
    var isEvent = false
    
    var users = [UserLightNeighborhood]()
    var usersSearch = [UserLightNeighborhood]()
    var isAlreadyClearRows = false
    var isSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = isEvent ? "event_users_title".localized : "neighborhood_users_title".localized
        let txtSearch = "neighborhood_group_search_empty_title".localized
        
        ui_top_view.populateView(title: title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = txtSearch
        ui_view_no_result.isHidden = true
        if isEvent {
            getEventusers()
        }
        else {
            getNeighborhoodUsers()
            AnalyticsLoggerManager.logEvent(name: View_GroupMember_ShowList)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    
    func getNeighborhoodUsers() {
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
    
    func getEventusers() {
        guard let event = event else {
            return
        }
        
        EventService.getEventUsers(eventId: event.uid, completion: { users, error in
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
extension NeighBorhoodEventListUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return usersSearch.count + 1
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            let title = isEvent ? "event_userInput_search".localized : "neighborhood_userInput_search".localized
            cell.populateCell(delegate: self, isSearch:isSearch,placeceholder:title, isCellUserSearch: true)
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
        
        cell.populateCell(isMe:isMe, username: user.displayName, role: user.getCommunityRoleWithPartnerFormated(), imageUrl: user.avatarURL, showBtMessage: true,delegate: self,position: position)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        
        var user:UserLightNeighborhood
        if isSearch {
            if !isEvent {
                AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_SeeResult)
            }
            user = self.usersSearch[indexPath.row - 1]
        }
        else {
            if !isEvent {
                AnalyticsLoggerManager.logEvent(name: Action_GroupMember_See1Member)
            }
            user = self.users[indexPath.row - 1]
        }
        
        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(user.sid)"
                
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
}

//MARK: - NeighborhoodHomeSearchDelegate  -
extension NeighBorhoodEventListUsersViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            if !isEvent {
                AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_Validate)
            }
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
extension NeighBorhoodEventListUsersViewController:NeighborhoodUserCellDelegate {
    func showSendMessageToUserForPosition(_ position: Int) {
        
        if !isEvent {
            AnalyticsLoggerManager.logEvent(name: Action_GroupMember_WriteTo1Member)
        }
        
        let user = isSearch ? usersSearch[position] : users[position]
        
        IHProgressHUD.show()
        MessagingService.createOrGetConversation(userId: "\(user.sid)") { conversation, error in
            IHProgressHUD.dismiss()
            
            if let conversation = conversation {
                self.showConversation(conversation: conversation, username: user.displayName)
                return
            }
            var errorMsg = "message_error_create_conversation".localized
            if let error = error {
                errorMsg = error.message
            }
            IHProgressHUD.showError(withStatus: errorMsg)
        }
    }
    
    private func showConversation(conversation:Conversation?, username:String) {
        DispatchQueue.main.async {
            if let convId = conversation?.uid {
                let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.setupFromOtherVC(conversationId: convId, title: username, isOneToOne: true, conversation: conversation)

                    self.present(vc, animated: true)
                }
            }
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighBorhoodEventListUsersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}
