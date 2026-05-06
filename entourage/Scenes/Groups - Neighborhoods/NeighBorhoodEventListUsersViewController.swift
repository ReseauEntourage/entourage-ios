//
//  NeighBorhoodEventListUsersViewController.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//  Fixed: checkbox flow (read real state), debounce, Hybrid Architecture (UIKit + SwiftUI Sticky Bottom & FAB).
//
import UIKit
import SwiftUI
import SVProgressHUD

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
    
    // Ancien bouton conservé en outlet pour ne pas faire crasher le storyboard,
    // mais on le désactive pour utiliser notre propre bouton SwiftUI.
    @IBOutlet weak var ui_floaty_button: Floaty!

    // SwiftUI Hybrid components
    private var bottomViewModel = UnsubscribedViewModel()
    private var bottomHostingController: UIHostingController<UnsubscribedBottomSwiftUIView>?

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
        
        // On masque l'ancien bouton UIKit pour utiliser celui de SwiftUI
        ui_floaty_button?.isHidden = true

        ui_tableview.register(UINib(nibName: SectionOptionNameCell.identifier, bundle: nil), forCellReuseIdentifier: SectionOptionNameCell.identifier)
        ui_tableview.register(UINib(nibName: QuestionSurveyVoteCell.identifier, bundle: nil), forCellReuseIdentifier: QuestionSurveyVoteCell.identifier)

        setupBottomViews()

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

        if isEvent, let eventId = event?.uid {
            EventService.getEventWithId(String(eventId)) { [weak self] event, error in
                guard let self = self, let event = event else { return }
                self.event?.metadata?.unsubscribed_participants_ask_for_help = event.metadata?.unsubscribed_participants_ask_for_help
                self.event?.metadata?.unsubscribed_participants_offer_help = event.metadata?.unsubscribed_participants_offer_help
                self.event?.metadata?.unsubscribed_participants_female = event.metadata?.unsubscribed_participants_female
                self.updateUnsubscribedBottomViews()
            }
        }
    }

    // MARK: - Survey
    func loadSurveyData() {
        guard let postId = self.postId, let survey = self.survey else { return }

        let completion: (SurveyResponsesListWrapper?, EntourageNetworkError?) -> Void = { [weak self] surveyResponsesListWrapper, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error != nil { return }
                guard let surveyResponsesList = surveyResponsesListWrapper?.responses, !surveyResponsesList.isEmpty else { return }

                self.tableData.removeAll()
                self.tableData.append(.questionCell(title: self.questionTitle ?? "Default Title"))

                for (index, choice) in survey.choices.enumerated() {
                    guard let voteCount = survey.summary[safe: index],
                          let usersForChoice = surveyResponsesList[safe: index] else { continue }

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
                    if !self.isSearch {
                        self.ui_view_no_result.isHidden = !self.users.isEmpty
                    }
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
                if error != nil {
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
                    if !self.isSearch {
                        self.ui_view_no_result.isHidden = !self.users.isEmpty
                    }
                }
            }
        }
    }

    private func rebuildTableDataFromUsers() {
        tableData = [.searchCell] + users.map { .userCell(user: $0, reactionType: nil) }
        ui_tableview.reloadData()
        updateUnsubscribedBottomViews()
    }

    // MARK: - SwiftUI Integration
    private func setupBottomViews() {
        guard isEvent else { return }

        // Configuration du bouton flottant SwiftUI
        bottomViewModel.showFab = viewerCanUseCheckboxes && !isFromSurvey && !isFromReact
        bottomViewModel.onFabTapped = { [weak self] in
            self?.showBottomSheet()
        }

        // Création du conteneur SwiftUI
        let swiftUIView = UnsubscribedBottomSwiftUIView(viewModel: bottomViewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.bottomHostingController = hostingController
    }

    private func updateUnsubscribedBottomViews() {
        guard isEvent, let event = event else { return }

        let askForHelp = Int(event.metadata?.unsubscribed_participants_ask_for_help ?? "0") ?? 0
        let offerHelp = Int(event.metadata?.unsubscribed_participants_offer_help ?? "0") ?? 0
        let femaleCount = Int(event.metadata?.unsubscribed_participants_female ?? "0") ?? 0

        // Met à jour l'interface SwiftUI
        bottomViewModel.askCount = askForHelp
        bottomViewModel.offerCount = offerHelp
        bottomViewModel.femaleCount = femaleCount

        // Ajuste le padding de la tableView pour pouvoir scroller jusqu'au bout
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let targetSize = CGSize(width: self.view.bounds.width, height: UIView.layoutFittingExpandedSize.height)
            let bottomHeight = self.bottomHostingController?.sizeThatFits(in: targetSize).height ?? 0
            
            self.ui_tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight + 20, right: 0)
        }
    }
    
    // MARK: - Show Bottom Sheet
    private func showBottomSheet() {
        let bottomSheet = UnsubscribedParticipantsBottomSheet()

        let initialAskStr = event?.metadata?.unsubscribed_participants_ask_for_help ?? "0"
        let initialOfferStr = event?.metadata?.unsubscribed_participants_offer_help ?? "0"
        let initialFemaleStr = event?.metadata?.unsubscribed_participants_female ?? "0"

        bottomSheet.initialAskCount = Int(initialAskStr) ?? 0
        bottomSheet.initialOfferCount = Int(initialOfferStr) ?? 0
        bottomSheet.initialFemaleCount = Int(initialFemaleStr) ?? 0

        bottomSheet.onDismiss = {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshEventDetail"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
        }
        bottomSheet.onValidate = { [weak self] (offerCount, askCount, femaleCount) in
            guard let self = self, let eventId = self.event?.uid else { return }

            SVProgressHUD.show()
            EventService.updateUnsubscribedParticipants(eventId: eventId, offerHelp: offerCount, askForHelp: askCount, female: femaleCount) { error in
                SVProgressHUD.dismiss()
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.message)
                } else {
                    if self.event?.metadata == nil { self.event?.metadata = EventMetadata() }
                    self.event?.metadata?.unsubscribed_participants_ask_for_help = String(askCount)
                    self.event?.metadata?.unsubscribed_participants_offer_help = String(offerCount)
                    self.event?.metadata?.unsubscribed_participants_female = String(femaleCount)
                    
                    self.updateUnsubscribedBottomViews()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshEventDetail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                }
            }
        }

        if #available(iOS 15.0, *) {
            if let sheet = bottomSheet.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in return 600 }
                    sheet.detents = [customDetent, .large()]
                } else {
                    sheet.detents = [.large()]
                }
                sheet.prefersGrabberVisible = true
            }
        } else {
            bottomSheet.modalPresentationStyle = .custom
        }

        self.present(bottomSheet, animated: true, completion: nil)
    }

    // MARK: - Search
    func searchUser(text: String) {
        usersSearch.removeAll()
        let searchedUsers = users.filter { $0.displayName.lowercased().contains(text.lowercased()) }
        usersSearch.append(contentsOf: searchedUsers)

        tableData = [.searchCell]
        if isSearch {
            if usersSearch.isEmpty {
                ui_view_no_result.isHidden = false
            } else {
                ui_view_no_result.isHidden = true
                tableData += searchedUsers.map { .userCell(user: $0, reactionType: nil) }
            }
        } else {
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
                    if !self.isSearch {
                        self.ui_view_no_result.isHidden = !self.users.isEmpty
                    }
                    self.ui_tableview.reloadData()
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
        } catch { return nil }
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
                position: indexPath.row,
                reactionType: reactionType,
                isParticipating: isParticipating,
                isOrganizer: isConfirmed,
                isCreator: viewerCanUseCheckboxes,
                isConfirmed: isConfirmed,
                isBirthday: user.isBirthday
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
            ui_view_no_result.isHidden = !users.isEmpty
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
        ui_view_no_result.isHidden = !usersSearch.isEmpty
    }
}

// MARK: - NeighborhoodUserCellDelegate (checkbox flow FIX)
extension NeighBorhoodEventListUsersViewController: NeighborhoodUserCellDelegate {

    func neighborhoodUserCell(_ cell: NeighborhoodUserCell, didRequestToggleAt tablePosition: Int, intendedChecked: Bool, completion: @escaping (_ finalChecked: Bool) -> Void) {

        guard isEvent, let eventId = event?.uid, tablePosition < tableData.count else {
            completion(!intendedChecked); return
        }
        guard case var .userCell(user, reaction) = tableData[tablePosition] else {
            completion(!intendedChecked); return
        }

        if pendingToggles.contains(tablePosition) { completion(!intendedChecked); return }
        pendingToggles.insert(tablePosition)

        cell.isUserInteractionEnabled = false
        SVProgressHUD.show()

        if intendedChecked {
            EventService.participateForUser(eventId: eventId, userId: user.sid) { [weak self] member, error in
                guard let self = self else { return }
                if let member = member {
                    user.participateAt = member.participateAt ?? ISO8601DateFormatter().string(from: Date())
                    user.confirmedAt = member.confirmedAt

                    if user.photoAcceptance == nil {
                        SVProgressHUD.dismiss()
                        self.presentPhotoConsent(for: user, eventId: eventId, tablePosition: tablePosition, reaction: reaction) { finalUser in
                            self.updateUserAndReload(user: finalUser, positionInTableData: tablePosition, reaction: reaction)
                            self.pendingToggles.remove(tablePosition)
                            completion(true)
                            cell.isUserInteractionEnabled = true
                        }
                    } else {
                        self.updateUserAndReload(user: user, positionInTableData: tablePosition, reaction: reaction)
                        SVProgressHUD.dismiss()
                        self.pendingToggles.remove(tablePosition)
                        completion(true)
                        cell.isUserInteractionEnabled = true
                    }
                } else {
                    SVProgressHUD.dismiss()
                    self.pendingToggles.remove(tablePosition)
                   SVProgressHUD.show(withStatus: error?.message ?? "Erreur lors de la confirmation.")
                    completion(false)
                    cell.isUserInteractionEnabled = true
                }
            }
        } else {
            EventService.cancelParticipationForUser(eventId: eventId, userId: user.sid) { [weak self] success, error in
                guard let self = self else { return }
                SVProgressHUD.dismiss()
                self.pendingToggles.remove(tablePosition)
                if success {
                    user.participateAt = nil
                    user.confirmedAt = nil
                    self.updateUserAndReload(user: user, positionInTableData: tablePosition, reaction: reaction)
                    completion(false)
                } else {
                   SVProgressHUD.show(withStatus: error?.message ?? "Erreur lors de l'annulation.")
                    completion(true)
                }
                cell.isUserInteractionEnabled = true
            }
        }
    }

    private func presentPhotoConsent(for user: UserLightNeighborhood, eventId: Int, tablePosition: Int, reaction: ReactionType?, completion: @escaping (UserLightNeighborhood) -> Void) {

        PhotoConsentPopupViewController.present(
            over: self,
            onAccept: { [weak self] in
                guard let self = self else { return }
                SVProgressHUD.show()
                EventService.acceptPhotoForUser(eventId: eventId, userId: user.sid) { ok, _ in
                    SVProgressHUD.dismiss()
                    var updated = user
                    updated.photoAcceptance = true
                    completion(updated)
                }
            },
            onDecline: { [weak self] in
                guard let self = self else { return }
                SVProgressHUD.show()
                EventService.cancelPhotoForUser(eventId: eventId, userId: user.sid) { _, _ in
                    SVProgressHUD.dismiss()
                    var updated = user
                    updated.photoAcceptance = false
                    completion(updated)
                }
            }
        )
    }

    private func updateUserAndReload(user: UserLightNeighborhood, positionInTableData: Int, reaction: ReactionType?) {
        tableData[positionInTableData] = .userCell(user: user, reactionType: reaction)
        let indexPath = IndexPath(row: positionInTableData, section: 0)
        ui_tableview.reloadRows(at: [indexPath], with: .automatic)

        if !isFromReact && !isFromSurvey && !isSearch {
            let userIndexInUsers = positionInTableData - 1
            if users.indices.contains(userIndexInUsers) {
                users[userIndexInUsers] = user
            }
        }
    }

    func showSendMessageToUserForPosition(_ tablePosition: Int) {
        guard tablePosition < tableData.count else { return }
        if case let .userCell(user, _) = tableData[tablePosition] {
            if !isEvent { AnalyticsLoggerManager.logEvent(name: Action_GroupMember_WriteTo1Member) }
            SVProgressHUD.show()
            MessagingService.createOrGetConversation(userId: "\(user.sid)") { conversation, error in
                SVProgressHUD.dismiss()
                if let conversation = conversation {
                    self.showConversation(conversation: conversation, username: user.displayName)
                    return
                }
                var errorMsg = "message_error_create_conversation".localized
                if let error = error { errorMsg = error.message }
               SVProgressHUD.show(withStatus: errorMsg)
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshEventDetail"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
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


// MARK: - SwiftUI View for Bottom Sticky Section & FAB

class UnsubscribedViewModel: ObservableObject {
    @Published var askCount: Int = 0
    @Published var offerCount: Int = 0
    @Published var femaleCount: Int = 0
    @Published var showFab: Bool = false
    var onFabTapped: (() -> Void)?
}

struct UnsubscribedBottomSwiftUIView: View {
    @ObservedObject var viewModel: UnsubscribedViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // 1. Fond blanc et contenu textuel (Sticky View)
            if viewModel.askCount > 0 || viewModel.offerCount > 0 || viewModel.femaleCount > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .background(Color.clear)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2)
                    
                    Text("PARTICIPANTS AJOUTÉS SUR PLACE")
                        .font(.system(size: 13, weight: .bold)) // Match ApplicationTheme
                        .foregroundColor(.black)
                        .padding(.top, 16)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)

                    if viewModel.askCount > 0 {
                        let title = viewModel.askCount > 1 ? "personnes isolées" : "personne isolée"
                        ParticipantRow(count: viewModel.askCount, title: title)
                    }

                    if viewModel.offerCount > 0 {
                        let title = viewModel.offerCount > 1 ? "riverains" : "riverain"
                        ParticipantRow(count: viewModel.offerCount, title: title)
                    }

                    if viewModel.femaleCount > 0 {
                        let title = viewModel.femaleCount > 1 ? "femmes isolées" : "femme isolée"
                        ParticipantRow(count: viewModel.femaleCount, title: title)
                    }
                    
                    // 🔥 On force un grand espace en bas de la Stack pour contourner la ligne/encoche système de l'iPhone
                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                // C'est ce background qui colore tout l'espace vide en dessous (safe area ignorée), MAIS le texte reste poussé vers le haut !
                .background(Color.white.ignoresSafeArea())
            } else {
                // Vue transparente invisible pour que le bouton puisse exister seul
                Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
            }

            // 2. Le Nouveau Bouton Flottant (+)
            if viewModel.showFab {
                Button(action: {
                    viewModel.onFabTapped?()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(UIColor(named: "appOrange") ?? .orange))
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 3)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                // 🔥 On remonte généreusement le bouton pour qu'il soit bien au-dessus du texte et de l'encoche
                .padding(.bottom, (viewModel.askCount > 0 || viewModel.offerCount > 0) ? 60 : 40)
            }
        }
        .animation(.easeInOut, value: viewModel.askCount)
        .animation(.easeInOut, value: viewModel.offerCount)
        .animation(.easeInOut, value: viewModel.showFab)
    }
}

struct ParticipantRow: View {
    var count: Int
    var title: String

    var body: some View {
        HStack(spacing: 16) {
            // Icone bonhomme orange
            ZStack {
                Circle()
                    .fill(Color(UIColor(named: "appOrange") ?? .orange).opacity(0.2))
                Image(systemName: "person.fill")
                    .foregroundColor(Color(UIColor(named: "appOrange") ?? .orange))
                    .font(.system(size: 18))
            }
            .frame(width: 48, height: 48)

            // Textes
            VStack(alignment: .leading, spacing: 4) {
                Text("\(count) \(title)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Text("Ajoutés sur place")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
}
