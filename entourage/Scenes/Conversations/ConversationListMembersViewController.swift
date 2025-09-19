//
//  ConversationListMembersViewController.swift
//  entourage
//

import UIKit
import IHProgressHUD

class ConversationListMembersViewController: BasePopViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!

    // MARK: - Mode & IDs
    var isSmallTalkMode = false
    var smallTalkId: String = ""
    var conversationId: Int?

    // MARK: - Data
    private var users       = [MemberLight]()
    private var usersSearch = [MemberLight]()
    private var userCreatorId: Int?

    // MARK: - Search state
    private var isSearch = false
    private var isAlreadyClearRows = false

    // MARK: - Pagination state
    private var currentPage = 1
    private let perPage = 20
    private var nextPage: Int? = 1
    private var isLoading = false

    // MARK: - Viewer capabilities
    /// Le viewer peut voir/utiliser les checkboxes s'il a au moins un rôle (non nul / non vide)
    private var viewerCanUseCheckboxes: Bool {
        // Adapte si tu as une autre source (ex: role de groupe / organisateur local, etc.)
        return !(UserDefaults.currentUser?.roles?.isEmpty ?? true)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        loadInitialData()
    }

    // MARK: - Public setup
    func setupFromSmallTalk(smallTalkId: String) {
        isSmallTalkMode = true
        self.smallTalkId = smallTalkId
    }

    // MARK: - UI Setup
    private func setupUI() {
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
    }

    private func setupTableView() {
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.tableFooterView = UIView()  // empty footer initially
    }

    // MARK: - Data Loading
    private func loadInitialData() {
        if isSmallTalkMode {
            // pas de détail à récupérer, on charge directement la première page
            loadParticipants(page: 1)
        } else {
            // récupérer la conversation pour connaitre l'auteur, puis la liste paginée
            guard let convoId = conversationId else {
                goBack()
                return
            }
            IHProgressHUD.show()
            MessagingService.getDetailConversation(conversationId: "\(convoId)") { [weak self] conversation, error in
                IHProgressHUD.dismiss()
                guard let self = self, let conversation = conversation else {
                    self?.goBack()
                    return
                }
                self.userCreatorId = conversation.author?.id
                self.loadParticipants(page: 1)
            }
        }
    }

    private func loadParticipants(page: Int) {
        guard !isLoading, nextPage != nil || page == 1 else { return }
        isLoading = true
        IHProgressHUD.show()

        let completion: ([MemberLight]?, Int?, EntourageNetworkError?) -> Void = { [weak self] pageUsers, next, error in
            guard let self = self else { return }
            IHProgressHUD.dismiss()
            self.isLoading = false

            if let pageUsers = pageUsers {
                if page == 1 {
                    self.users = pageUsers
                } else {
                    self.users.append(contentsOf: pageUsers)
                }
                self.nextPage = next
            }

            DispatchQueue.main.async {
                self.ui_tableview.reloadData()
                self.ui_tableview.tableFooterView = (self.nextPage != nil)
                    ? self.makeLoadingFooter()
                    : UIView()
            }
        }

        if isSmallTalkMode {
            SmallTalkService.listParticipants(id: smallTalkId,
                                              page: page,
                                              per: perPage) { items, next, err in
                let mapped = items?.map {
                    MemberLight(uid: $0.sid,
                                username: $0.displayName,
                                imageUrl: $0.avatarURL,
                                confirmedAt: nil)
                }
                completion(mapped, next, err)
            }
        } else {
            guard let convoId = conversationId else { return }
            MessagingService.getUsersForConversation(conversationId: convoId,
                                                     page: page,
                                                     per: perPage) { items, next, err in
                completion(items, next, err)
            }
        }
    }

    private func makeLoadingFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0,
                                          width: view.bounds.width,
                                          height: 44))
        if #available(iOS 13.0, *) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.center = footer.center
            spinner.startAnimating()
            footer.addSubview(spinner)
        } else {
            // Fallback on earlier versions
        }

        return footer
    }

    // MARK: - Search
    func searchUser(text: String) {
        usersSearch = users.filter {
            $0.username?.lowercased().contains(text.lowercased()) ?? false
        }
        ui_view_no_result.isHidden = !usersSearch.isEmpty
        ui_tableview.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ConversationListMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // +1 pour la cellule de recherche
        let count = isSearch ? usersSearch.count : users.count
        return count + 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cellule de recherche
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell_search",
                for: indexPath
            ) as! NeighborhoodHomeSearchCell
            cell.populateCell(
                delegate: self,
                isSearch: isSearch,
                placeceholder: "conversation_userInput_search".localized,
                isCellUserSearch: true
            )
            return cell
        }

        // cellule utilisateur
        let position = indexPath.row - 1
        let user = isSearch ? usersSearch[position] : users[position]
        let isMe = user.uid == UserDefaults.currentUser?.sid
        let isAuthor = user.uid == userCreatorId
        let isParticipating = (user.participateAt != nil)
        let isConfirmed = (user.confirmedAt != nil)

        let any = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath)
        print("Dequeued:", type(of: any))
        guard let cell = any as? NeighborhoodUserCell else { fatalError("Wrong class") }
        
        cell.populateCell(
            isMe: isMe,
            username: user.username ?? "-",
            role: isAuthor ? "Admin".localized : "",
            imageUrl: user.imageUrl,
            showBtMessage: true,
            delegate: self,
            position: position,
            reactionType: nil,
            isParticipating: isParticipating,
            isOrganizer: viewerCanUseCheckboxes,
            isCreator: isAuthor,
            isConfirmed: isConfirmed
        )
        return cell
    }
}

// MARK: - UITableViewDelegate (pagination & selection)
extension ConversationListMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        // si on atteint la dernière « vraie » cellule, on charge la page suivante
        let total = isSearch ? usersSearch.count : users.count
        if indexPath.row == total && nextPage != nil {
            loadParticipants(page: nextPage!)
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        let user = isSearch
            ? usersSearch[indexPath.row - 1]
            : users[indexPath.row - 1]

        if let navVC = UIStoryboard(name: StoryboardName.profileParams,
                                    bundle: nil)
            .instantiateViewController(withIdentifier: "profileFull")
                as? UINavigationController,
           let profileVC = navVC.topViewController
                as? ProfilFullViewController {
            profileVC.userIdToDisplay = "\(user.uid)"
            present(navVC, animated: true)
        }
    }
}

// MARK: - NeighborhoodHomeSearchDelegate
extension ConversationListMembersViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            isSearch = true
            searchUser(text: text)
        } else {
            // reset
            isSearch = false
            usersSearch.removeAll()
            isAlreadyClearRows = false
            ui_view_no_result.isHidden = true
            ui_tableview.reloadData()
        }
    }

    func showEmptySearch() {
        // gère le moment où l'utilisateur appuie sur la loupe sans texte
        isSearch = true
        isAlreadyClearRows.toggle()
        ui_view_no_result.isHidden = true
        ui_tableview.reloadData()
    }
}

// MARK: - NeighborhoodUserCellDelegate
extension ConversationListMembersViewController: NeighborhoodUserCellDelegate {
    func neighborhoodUserCell(_ cell: NeighborhoodUserCell,
                              didRequestToggleAt position: Int,
                              intendedChecked isChecked: Bool,
                                  completion: @escaping (Bool) -> Void) {

            // On utilise conversationId comme eventId
            guard let eid = conversationId else {
                completion(false)
                return
            }

            // Récup de l'utilisateur ciblé (safe index)
            let candidate = isSearch ? usersSearch[safe: position] : users[safe: position]
            guard let target = candidate else {
                completion(false)
                return
            }
            let userId = target.uid  // <- non optionnel, pas de 'guard let'

            if isChecked {
                // Popup consentement, puis acceptPhoto -> participate
                PhotoConsentPopupViewController.present(over: self, onAccept: { [weak self] in
                    guard let self = self else { return }
                    IHProgressHUD.show()

                    EventService.acceptPhotoForUser(eventId: eid, userId: userId) { _, _ in
                        EventService.participateForUser(eventId: eid, userId: userId) { member, error in
                            IHProgressHUD.dismiss()
                            if member != nil {
                                completion(true) // garder coché
                            } else {
                                IHProgressHUD.showError(withStatus: error?.message ?? "Une erreur est survenue.")
                                completion(false) // rétablir décoché
                            }
                        }
                    }
                }, onDecline: {
                    completion(false) // refus -> on re-décoche
                })

            } else {
                // Annuler la participation
                IHProgressHUD.show()
                EventService.cancelParticipationForUser(eventId: eid, userId: userId) { success, error in
                    IHProgressHUD.dismiss()
                    if success {
                        completion(true) // garder décoché
                    } else {
                        IHProgressHUD.showError(withStatus: error?.message ?? "Impossible d’annuler la participation.")
                        completion(false) // rétablir coché
                    }
                }
            }
        }
    
    func showSendMessageToUserForPosition(_ position: Int) {
        let user = isSearch ? usersSearch[position] : users[position]
        IHProgressHUD.show()

        if isSmallTalkMode {
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC")
                    as? ConversationDetailMessagesViewController,
               let smallTalkIdInt = Int(smallTalkId) {
                vc.setupFromSmallTalk(smallTalkId: smallTalkIdInt,
                                      title: "Bonnes ondes",
                                      delegate: nil)
                IHProgressHUD.dismiss()
                present(vc, animated: true)
            }
        } else {
            MessagingService.createOrGetConversation(userId: "\(user.uid)") { [weak self] conversation, error in
                IHProgressHUD.dismiss()
                guard let self = self, let conv = conversation else {
                    IHProgressHUD.showError(
                        withStatus: error?.message
                            ?? "message_error_create_conversation".localized
                    )
                    return
                }
                self.presentConversation(conv, username: user.username)
            }
        }
    }

    private func presentConversation(_ conversation: Conversation,
                                     username: String?) {
        DispatchQueue.main.async {
            let sb = UIStoryboard(name: StoryboardName.messages, bundle: nil)
            if let vc = sb.instantiateViewController(
                    withIdentifier: "detailMessagesVC"
                ) as? ConversationDetailMessagesViewController {
                vc.setupFromOtherVC(
                    conversationId: conversation.uid,
                    title: username,
                    isOneToOne: true,
                    conversation: conversation
                )
                self.present(vc, animated: true)
            }
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension ConversationListMembersViewController: MJNavBackViewDelegate {
    func goBack() {
        dismiss(animated: true)
    }
    func didTapEvent() {
        // pas utilisé ici
    }
}
