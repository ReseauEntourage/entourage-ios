//
//  ConversationListMembersViewController.swift
//  entourage
//
//  Created by Jerome on 26/08/2022.
//

import UIKit
import IHProgressHUD

class ConversationListMembersViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!
    
    var users = [MemberLight]()
    var usersSearch = [MemberLight]()
    var isAlreadyClearRows = false
    var isSearch = false
    
    var userCreatorId:Int? = nil
    
    var conversationId:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = "conversation_users_title".localized
        let txtSearch = "conversation_search_empty_title".localized
        
        ui_top_view.populateView(title: title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = txtSearch
        ui_view_no_result.isHidden = true
        
        getConversation()
    }
    
    func getConversation() {
        guard let conversationId = conversationId else {
            self.goBack()
            return
        }
        var _convId = ""
        if self.conversationId != 0 {
            _convId = String(conversationId)
        }
        MessagingService.getDetailConversation(conversationId: _convId) { conversation, error in
            if let conversation = conversation,let members = conversation.members {
                self.users = members
                self.userCreatorId = conversation.author?.id
            }
            
            self.ui_tableview.reloadData()
        }
    }
    
    func searchUser(text:String) {
        usersSearch.removeAll()
        let _searched = users.filter( { $0.username!.lowercased().contains(text.lowercased()) } )
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
extension ConversationListMembersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return usersSearch.count + 1
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            let title = "conversation_userInput_search".localized
            cell.populateCell(delegate: self, isSearch:isSearch,placeceholder:title, isCellUserSearch: true)
            return cell
        }
        
        var user:MemberLight
        let position = indexPath.row - 1
        
        if isSearch {
            user = self.usersSearch[position]
        }
        else {
            user = self.users[position]
        }
        
        let isMe = user.uid == UserDefaults.currentUser?.sid
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! NeighborhoodUserCell
        
        let isAuthor = user.uid == userCreatorId
        
        cell.populateCell(isMe:isMe, username: user.username ?? "-", role: isAuthor ? "Admin".localized : "", imageUrl: user.imageUrl, showBtMessage: true,delegate: self,position: position, reactionType: nil, isConfirmed: user.confirmedAt, isOrganizer: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        
        var user:MemberLight
        if isSearch {
            user = self.usersSearch[indexPath.row - 1]
        }
        else {
            user = self.users[indexPath.row - 1]
        }
        
        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(user.uid)"
                
                self.present(navVC, animated: true)
            }
        }
    }
}

//MARK: - NeighborhoodHomeSearchDelegate  -
extension ConversationListMembersViewController: NeighborhoodHomeSearchDelegate {
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
extension ConversationListMembersViewController:NeighborhoodUserCellDelegate {
    func showSendMessageToUserForPosition(_ position: Int) {
        let user = isSearch ? usersSearch[position] : users[position]
        
        IHProgressHUD.show()
        MessagingService.createOrGetConversation(userId: "\(user.uid)") { conversation, error in
            IHProgressHUD.dismiss()
            
            if let conversation = conversation {
                self.showConversation(conversation: conversation, username: user.username)
                return
            }
            var errorMsg = "message_error_create_conversation".localized
            if let error = error {
                errorMsg = error.message
            }
            IHProgressHUD.showError(withStatus: errorMsg)
        }
    }
    
    private func showConversation(conversation:Conversation?, username:String?) {
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
extension ConversationListMembersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}
