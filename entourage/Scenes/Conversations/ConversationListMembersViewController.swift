//
//  ConversationListMembersViewController.swift
//  entourage
//

import UIKit
import IHProgressHUD

class ConversationListMembersViewController: BasePopViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!

    var isSmallTalkMode = false
    var smallTalkId: String = ""

    var users = [MemberLight]()
    var usersSearch = [MemberLight]()
    var isAlreadyClearRows = false
    var isSearch = false

    var userCreatorId: Int? = nil
    var conversationId: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        ui_top_view.populateView(
            title: "conversation_users_title".localized,
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
            titleColor: .black,
            delegate: self,
            isClose: true
        )

        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = "conversation_search_empty_title".localized
        ui_view_no_result.isHidden = true

        getConversation()
    }

    func setupFromSmallTalk(smallTalkId: String) {
        self.isSmallTalkMode = true
        self.smallTalkId = smallTalkId
    }

    func getConversation() {
        IHProgressHUD.show()

        if isSmallTalkMode {
            SmallTalkService.listParticipants(id: smallTalkId) { participants, error in
                IHProgressHUD.dismiss()

                guard let participants = participants else {
                    self.goBack()
                    return
                }

                self.users = participants.map { user in
                    MemberLight(
                        uid: user.sid,
                        username: user.displayName,
                        imageUrl: user.avatarURL,
                        confirmedAt: nil
                    )
                }
                DispatchQueue.main.async {
                    self.ui_tableview.reloadData()
                }
            }
            return
        }

        guard let conversationId = conversationId else {
            IHProgressHUD.dismiss()
            self.goBack()
            return
        }

        let idAsString = String(conversationId)

        MessagingService.getDetailConversation(conversationId: idAsString) { conversation, error in
            if let conversation = conversation {
                self.userCreatorId = conversation.author?.id
            }

            MessagingService.getUsersForConversation(conversationId: conversationId) { users, error in
                IHProgressHUD.dismiss()
                if let users = users {
                    self.users = users
                }
                self.ui_tableview.reloadData()
            }
        }
    }

    func searchUser(text: String) {
        usersSearch.removeAll()
        let _searched = users.filter { $0.username?.lowercased().contains(text.lowercased()) ?? false }
        usersSearch.append(contentsOf: _searched)
        ui_view_no_result.isHidden = !usersSearch.isEmpty
        ui_tableview.reloadData()
    }
}

// MARK: - TableView Datasource & Delegate
extension ConversationListMembersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearch ? usersSearch.count : users.count) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            cell.populateCell(
                delegate: self,
                isSearch: isSearch,
                placeceholder: "conversation_userInput_search".localized,
                isCellUserSearch: true
            )
            return cell
        }

        let position = indexPath.row - 1
        let user = isSearch ? usersSearch[position] : users[position]
        let isMe = user.uid == UserDefaults.currentUser?.sid
        let isAuthor = user.uid == userCreatorId

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! NeighborhoodUserCell

        cell.populateCell(
            isMe: isMe,
            username: user.username ?? "-",
            role: isAuthor ? "Admin".localized : "",
            imageUrl: user.imageUrl,
            showBtMessage: true,
            delegate: self,
            position: position,
            reactionType: nil,
            isConfirmed: user.confirmedAt,
            isOrganizer: false,
            isCreator: isAuthor
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }

        let user = isSearch ? usersSearch[indexPath.row - 1] : users[indexPath.row - 1]

        if let navVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
            .instantiateViewController(withIdentifier: "profileFull") as? UINavigationController,
           let profileVC = navVC.topViewController as? ProfilFullViewController {
            profileVC.userIdToDisplay = "\(user.uid)"
            self.present(navVC, animated: true)
        }
    }
}

// MARK: - Search Delegate
extension ConversationListMembersViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            searchUser(text: text)
        } else {
            usersSearch.removeAll()
            isAlreadyClearRows = false
            isSearch = false
            ui_view_no_result.isHidden = true
            ui_tableview.reloadData()
        }
    }

    func showEmptySearch() {
        isSearch = true
        if !isAlreadyClearRows {
            isAlreadyClearRows = true
            ui_tableview.reloadData()
        } else {
            isAlreadyClearRows = false
        }
        ui_view_no_result.isHidden = true
    }
}

// MARK: - Cell Delegate
extension ConversationListMembersViewController: NeighborhoodUserCellDelegate {
    func showSendMessageToUserForPosition(_ position: Int) {
        let user = isSearch ? usersSearch[position] : users[position]

        IHProgressHUD.show()

        if isSmallTalkMode {
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                if let smallTalkIdInt = Int(self.smallTalkId) {
                    vc.setupFromSmallTalk(smallTalkId: smallTalkIdInt, title: "Bonnes ondes", delegate: nil)
                }
                IHProgressHUD.dismiss()
                self.present(vc, animated: true)
            }
        } else {
            MessagingService.createOrGetConversation(userId: "\(user.uid)") { conversation, error in
                IHProgressHUD.dismiss()

                if let conversation = conversation {
                    self.showConversation(conversation: conversation, username: user.username)
                } else {
                    IHProgressHUD.showError(withStatus: error?.message ?? "message_error_create_conversation".localized)
                }
            }
        }
    }

    private func showConversation(conversation: Conversation?, username: String?) {
        DispatchQueue.main.async {
            if let convId = conversation?.uid {
                let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.setupFromOtherVC(
                        conversationId: convId,
                        title: username,
                        isOneToOne: true,
                        conversation: conversation
                    )
                    self.present(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension ConversationListMembersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }

    func didTapEvent() {
        // Pas utilisé ici
    }
}
