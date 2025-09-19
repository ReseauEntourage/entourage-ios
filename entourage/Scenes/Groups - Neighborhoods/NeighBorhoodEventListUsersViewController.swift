//
//  NeighBorhoodEventListUsersViewController.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//  Fixed: checkbox flow (read real state), debounce, no event loops.
//
import UIKit
import IHProgressHUD

private enum TableDTO {
    case searchCell
    case questionCell(title: String)
    case userCell(user: UserLightNeighborhood, reactionType: ReactionType?)
    case surveySection(title: String, voteCount: Int)
}

class NeighBorhoodEventListUsersViewController: BasePopViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_lb_no_result: UILabel!
    @IBOutlet weak var ui_view_no_result: UIView!

    var neighborhood: Neighborhood? = nil
    var event: Event? = nil
    var isEvent = false

    var users = [UserLightNeighborhood]()
    var usersSearch = [UserLightNeighborhood]()

    var isAlreadyClearRows = false
    var isSearch = false

    var reactionsTypes = [ReactionType]()
    var groupId: Int? = nil
    var postId: Int? = nil
    var isFromReact = false

    var eventId: Int? = nil

    // Survey
    var survey: Survey? = nil
    var questionTitle: String? = nil
    var isFromSurvey = false

    var reactionTypeList = [ReactionType]()

    // Data model used by the table
    private var tableData: [TableDTO] = []

    // Pagination
    private var currentPage = 1
    private let perPage = 20
    private var isLoading = false
    private var hasMorePages = true

    // Debounce to prevent repeated toggles
    private var pendingToggles = Set<Int>() // indexes in tableData

    // MARK: - Viewer capabilities
    private var viewerCanUseCheckboxes: Bool {
        return !(UserDefaults.currentUser?.roles?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableview.register(UINib(nibName: SectionOptionNameCell.identifier, bundle: nil), forCellReuseIdentifier: SectionOptionNameCell.identifier)
        ui_tableview.register(UINib(nibName: QuestionSurveyVoteCell.identifier, bundle: nil), forCellReuseIdentifier: QuestionSurveyVoteCell.identifier)

        var title = isEvent ? "event_users_title".localized : "neighborhood_users_title".localized
        if isFromReact { title = "see_member_react".localized }
        if isFromSurvey { title = "Réponses au sondage" }

        let txtSearch = "neighborhood_group_search_empty_title".localized

        loadStoredReactionTypes()

        ui_top_view.populateView(title: title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = txtSearch
        ui_view_no_result.isHidden = true

        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.tableFooterView = UIView()

        if isFromSurvey {
            loadSurveyData()
        } else if isFromReact {
            fetchReactionsDetails()
        } else {
            if isEvent {
                getEventusers()
            } else {
                getNeighborhoodUsers()
                AnalyticsLoggerManager.logEvent(name: View_GroupMember_ShowList)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }

    // MARK: - Survey
    func loadSurveyData() {
        guard let postId = self.postId, let survey = self.survey else {
            print("Survey information or postId is missing.")
            return
        }

        let completion: (SurveyResponsesListWrapper?, EntourageNetworkError?) -> Void = { [weak self] surveyResponsesListWrapper, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error retrieving survey responses: \(error)")
                    return
                }
                guard let surveyResponsesList = surveyResponsesListWrapper?.responses, !surveyResponsesList.isEmpty else {
                    print("No survey responses were found or the response list is empty.")
                    return
                }

                self.tableData.removeAll()
                self.tableData.append(.questionCell(title: self.questionTitle ?? "Default Title"))

                for (index, choice) in survey.choices.enumerated() {
                    guard let voteCount = survey.summary[safe: index],
                          let usersForChoice = surveyResponsesList[safe: index] else {
                        print("Index \(index) is out of bounds.")
                        continue
                    }

                    self.tableData.append(.surveySection(title: choice, voteCount: voteCount))

                    self.tableData += usersForChoice.map { surveyUser in
                        var userLight = UserLightNeighborhood()
                        userLight.sid = surveyUser.id
                        userLight.displayName = surveyUser.displayName
                        userLight.avatarURL = surveyUser.avatarUrl
                        userLight.communityRoles = surveyUser.communityRoles
                        return TableDTO.userCell(user: userLight, reactionType: nil)
                    }
                }

                self.ui_tableview.reloadData()
            }
        }

        if let eventId = self.eventId {
            SurveyService.getSurveyResponsesForEvent(eventId: eventId, postId: postId, completion: completion)
        } else if let groupId = self.groupId {
            SurveyService.getSurveyResponsesForGroup(groupId: groupId, postId: postId, completion: completion)
        }
    }

    // MARK: - Neighborhood / Event users
    func getNeighborhoodUsers() {
        guard let neighborhood = neighborhood else { return }
        isLoading = true

        NeighborhoodService.getNeighborhoodUsers(neighborhoodId: neighborhood.uid, page: currentPage, per: perPage) { [weak self] users, nextPage, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let users = users {
                    if self.currentPage == 1 {
                        self.users = users
                    } else {
                        self.users.append(contentsOf: users)
                    }
                    self.rebuildTableDataFromUsers()
                    self.currentPage = nextPage ?? self.currentPage
                    self.hasMorePages = nextPage != nil
                } else if let error = error {
                    print("Erreur lors de la récupération des utilisateurs: \(error)")
                }
            }
        }
    }

    func getEventusers() {
        guard let event = event else { return }
        isLoading = true

        EventService.getEventUsers(eventId: event.uid, page: currentPage, per: perPage) { [weak self] users, nextPage, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Erreur lors de la récupération des utilisateurs de l'événement: \(error)")
                    self.goBack()
                    return
                }
                if let users = users {
                    if self.currentPage == 1 {
                        self.users = users
                    } else {
                        self.users.append(contentsOf: users)
                    }
                    self.rebuildTableDataFromUsers()
                    self.currentPage = nextPage ?? self.currentPage
                    self.hasMorePages = nextPage != nil
                    self.ui_view_no_result.isHidden = !users.isEmpty
                }
            }
        }
    }

    private func rebuildTableDataFromUsers() {
        tableData = [.searchCell] + users.map { .userCell(user: $0, reactionType: nil) }
        ui_tableview.reloadData()
    }

    // MARK: - Search
    func searchUser(text: String) {
        usersSearch.removeAll()
        let searchedUsers = users.filter { $0.displayName.lowercased().contains(text.lowercased()) }
        usersSearch.append(contentsOf: searchedUsers)

        tableData = [.searchCell]
        if usersSearch.isEmpty {
            ui_view_no_result.isHidden = false
        } else {
            ui_view_no_result.isHidden = true
            tableData += searchedUsers.map { .userCell(user: $0, reactionType: nil) }
        }
        ui_tableview.reloadData()
    }

    // MARK: - Reactions (details)
    func fetchReactionsDetails() {
        guard let postId = self.postId else { return }

        let completion: (CompleteReactionsResponse?, EntourageNetworkError?) -> Void = { [weak self] response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let userReactions = response?.userReactions {
                    self.users = userReactions.map { $0.user }
                    self.reactionTypeList = userReactions.map { ReactionType(id: $0.reactionId, key: nil, imageUrl: nil) }

                    self.tableData.removeAll()
                    self.tableData = [.searchCell]
                    for (idx, user) in self.users.enumerated() {
                        self.tableData.append(.userCell(user: user, reactionType: self.reactionTypeList[safe: idx]))
                    }
                    self.ui_tableview.reloadData()
                } else if let error = error {
                    print("Erreur lors de la récupération des détails des réactions: \(error)")
                }
            }
        }

        if let groupId = self.groupId {
            NeighborhoodService.getPostReactionsDetails(groupId: groupId, postId: postId, completion: completion)
        } else if let eventId = self.eventId {
            EventService.getEventPostReactionDetails(eventId: eventId, postId: postId, completion: completion)
        }
    }

    // Stored reactions sprites
    func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        do {
            return try JSONDecoder().decode([ReactionType].self, from: reactionsData)
        } catch {
            print("Erreur de décodage des réactions : \(error)")
            return nil
        }
    }
    func loadStoredReactionTypes() {
        reactionsTypes = getStoredReactionTypes() ?? []
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension NeighBorhoodEventListUsersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }

        let threshold = 5
        if !isFromReact && !isFromSurvey && indexPath.row >= tableData.count - threshold && hasMorePages && !isLoading {
            if isEvent { getEventusers() } else { getNeighborhoodUsers() }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableData[indexPath.row] {

        case .searchCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            let title = isEvent ? "event_userInput_search".localized : "neighborhood_userInput_search".localized
            cell.populateCell(delegate: self, isSearch: isSearch, placeceholder: title, isCellUserSearch: true)
            return cell

        case .userCell(let user, let reactionType):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! NeighborhoodUserCell

            let isMe = user.sid == UserDefaults.currentUser?.sid
            let isParticipating = (user.participateAt != nil)
            let isConfirmed = (user.confirmedAt != nil)
            cell.populateCell(
                isMe: isMe,
                username: user.displayName,
                role: user.getCommunityRoleWithPartnerFormated(),
                imageUrl: user.avatarURL,
                showBtMessage: true,
                delegate: self,
                position: indexPath.row,              // exact index in tableData
                reactionType: reactionType,
                isParticipating: isParticipating,
                isOrganizer: isConfirmed,
                isCreator: viewerCanUseCheckboxes,
                isConfirmed: isConfirmed
            )
            cell.hideSeparatorBarIfIsVote(isVote: self.isFromSurvey)
            return cell

        case .surveySection(let title, let voteCount):
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: SectionOptionNameCell.identifier) as! SectionOptionNameCell
            cell.selectionStyle = .none
            cell.configure(title: title, countVote: voteCount)
            return cell

        case .questionCell(let title):
            let cell = ui_tableview.dequeueReusableCell(withIdentifier: QuestionSurveyVoteCell.identifier) as! QuestionSurveyVoteCell
            cell.selectionStyle = .none
            cell.configure(title: title)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData[indexPath.row] {
        case .searchCell, .surveySection, .questionCell:
            return

        case .userCell(_, _):
            var tappedUser: UserLightNeighborhood?

            if isSearch {
                if !isEvent { AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_SeeResult) }
                if indexPath.row - 1 < usersSearch.count {
                    tappedUser = usersSearch[indexPath.row - 1]
                }
            } else {
                if !isEvent { AnalyticsLoggerManager.logEvent(name: Action_GroupMember_See1Member) }
                if indexPath.row - 1 < users.count {
                    tappedUser = users[indexPath.row - 1]
                }
            }

            if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
                if let u = tappedUser { profileVC.userIdToDisplay = "\(u.sid)" }
                profileVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(profileVC, animated: true)
            }
        }
    }
}

// MARK: - NeighborhoodHomeSearchDelegate
extension NeighBorhoodEventListUsersViewController: NeighborhoodHomeSearchDelegate {
    func goSearch(_ text: String?) {
        if let text = text, !text.isEmpty {
            if !isEvent { AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_Validate) }
            self.searchUser(text: text)
        } else {
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
        } else {
            isAlreadyClearRows = false
        }
        ui_view_no_result.isHidden = true
    }
}

// MARK: - NeighborhoodUserCellDelegate (checkbox flow FIX)
extension NeighBorhoodEventListUsersViewController: NeighborhoodUserCellDelegate {

    func neighborhoodUserCell(_ cell: NeighborhoodUserCell,
                              didRequestToggleAt tablePosition: Int,
                              intendedChecked: Bool,
                              completion: @escaping (_ finalChecked: Bool) -> Void) {

        guard isEvent, let eventId = event?.uid, tablePosition < tableData.count else {
            completion(!intendedChecked) // revert
            return
        }
        guard case var .userCell(user, reaction) = tableData[tablePosition] else {
            completion(!intendedChecked)
            return
        }

        // Debounce repeated valueChanged while we are processing
        if pendingToggles.contains(tablePosition) {
            completion(!intendedChecked) // keep current UI
            return
        }
        pendingToggles.insert(tablePosition)

        cell.isUserInteractionEnabled = false
        IHProgressHUD.show()

        if intendedChecked {
            // CHECK ⇒ participate then maybe ask for photo consent
            EventService.participateForUser(eventId: eventId, userId: user.sid) { [weak self] member, error in
                guard let self = self else { return }
                if let member = member {
                    user.participateAt = member.participateAt ?? ISO8601DateFormatter().string(from: Date())
                    user.confirmedAt = member.confirmedAt

                    if user.photoAcceptance == nil {
                        IHProgressHUD.dismiss()
                        self.presentPhotoConsent(for: user, eventId: eventId, tablePosition: tablePosition, reaction: reaction) { finalUser in
                            self.updateUserAndReload(user: finalUser, positionInTableData: tablePosition, reaction: reaction)
                            self.pendingToggles.remove(tablePosition)
                            completion(true)
                            cell.isUserInteractionEnabled = true
                        }
                    } else {
                        self.updateUserAndReload(user: user, positionInTableData: tablePosition, reaction: reaction)
                        IHProgressHUD.dismiss()
                        self.pendingToggles.remove(tablePosition)
                        completion(true)
                        cell.isUserInteractionEnabled = true
                    }
                } else {
                    IHProgressHUD.dismiss()
                    self.pendingToggles.remove(tablePosition)
                    IHProgressHUD.showError(withStatus: error?.message ?? "Erreur lors de la confirmation.")
                    completion(false) // revert
                    cell.isUserInteractionEnabled = true
                }
            }
        } else {
            // UNCHECK ⇒ cancel participation (do not touch photo consent)
            EventService.cancelParticipationForUser(eventId: eventId, userId: user.sid) { [weak self] success, error in
                guard let self = self else { return }
                IHProgressHUD.dismiss()
                self.pendingToggles.remove(tablePosition)
                if success {
                    user.participateAt = nil
                    user.confirmedAt = nil
                    self.updateUserAndReload(user: user, positionInTableData: tablePosition, reaction: reaction)
                    completion(false)
                } else {
                    IHProgressHUD.showError(withStatus: error?.message ?? "Erreur lors de l'annulation.")
                    completion(true) // revert
                }
                cell.isUserInteractionEnabled = true
            }
        }
    }

    private func presentPhotoConsent(for user: UserLightNeighborhood,
                                     eventId: Int,
                                     tablePosition: Int,
                                     reaction: ReactionType?,
                                     completion: @escaping (UserLightNeighborhood) -> Void) {

        PhotoConsentPopupViewController.present(
            over: self,
            onAccept: { [weak self] in
                guard let self = self else { return }
                IHProgressHUD.show()
                EventService.acceptPhotoForUser(eventId: eventId, userId: user.sid) { ok, _ in
                    IHProgressHUD.dismiss()
                    var updated = user
                    updated.photoAcceptance = true
                    completion(updated)
                }
            },
            onDecline: { [weak self] in
                guard let self = self else { return }
                IHProgressHUD.show()
                EventService.cancelPhotoForUser(eventId: eventId, userId: user.sid) { _, _ in
                    IHProgressHUD.dismiss()
                    var updated = user
                    updated.photoAcceptance = false
                    completion(updated)
                }
            }
        )
    }

    private func updateUserAndReload(user: UserLightNeighborhood,
                                     positionInTableData: Int,
                                     reaction: ReactionType?) {
        tableData[positionInTableData] = .userCell(user: user, reactionType: reaction)
        let indexPath = IndexPath(row: positionInTableData, section: 0)
        ui_tableview.reloadRows(at: [indexPath], with: .automatic)

        if !isFromReact && !isFromSurvey && !isSearch {
            let userIndexInUsers = positionInTableData - 1 // account for search cell at 0
            if users.indices.contains(userIndexInUsers) {
                users[userIndexInUsers] = user
            }
        }
    }

    func showSendMessageToUserForPosition(_ tablePosition: Int) {
        guard tablePosition < tableData.count else { return }
        if case let .userCell(user, _) = tableData[tablePosition] {
            if !isEvent { AnalyticsLoggerManager.logEvent(name: Action_GroupMember_WriteTo1Member) }
            IHProgressHUD.show()
            MessagingService.createOrGetConversation(userId: "\(user.sid)") { conversation, error in
                IHProgressHUD.dismiss()
                if let conversation = conversation {
                    self.showConversation(conversation: conversation, username: user.displayName)
                    return
                }
                var errorMsg = "message_error_create_conversation".localized
                if let error = error { errorMsg = error.message }
                IHProgressHUD.showError(withStatus: errorMsg)
            }
        }
    }

    private func showConversation(conversation: Conversation?, username: String) {
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

// MARK: - MJNavBackViewDelegate
extension NeighBorhoodEventListUsersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
    func didTapEvent() { /* no-op */ }
}

// MARK: - Safe subscript
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
