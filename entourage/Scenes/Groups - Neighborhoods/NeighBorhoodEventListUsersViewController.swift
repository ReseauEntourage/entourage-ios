//
//  NeighBorhoodListUsersViewController.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//

import UIKit
import IHProgressHUD

private enum TableDTO {
    case searchCell
    case questionCell(title:String)
    case userCell(user: UserLightNeighborhood, reactionType: ReactionType?)
    case surveySection(title: String, voteCount: Int)

}


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
    
    var reactionsTypes = [ReactionType]()
    var groupId: Int? = nil
    var postId: Int? = nil
    var isFromReact = false
    var eventId:Int? = nil
    var survey:Survey? = nil
    var questionTitle:String? = nil
    var isFromSurvey = false
    var reactionTypeList = [ReactionType]()
    private var tableData: [TableDTO] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.register(UINib(nibName: SectionOptionNameCell.identifier, bundle: nil), forCellReuseIdentifier: SectionOptionNameCell.identifier)
        ui_tableview.register(UINib(nibName: QuestionSurveyVoteCell.identifier, bundle: nil), forCellReuseIdentifier: QuestionSurveyVoteCell.identifier)

        var title = isEvent ? "event_users_title".localized : "neighborhood_users_title".localized
        if isFromReact {
            title = "see_member_react".localized
        }
        if isFromSurvey {
            title = "Réponses au sondage"
        }
        let txtSearch = "neighborhood_group_search_empty_title".localized
        loadStoredReactionTypes()

        ui_top_view.populateView(title: title, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
        
        ui_lb_no_result.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lb_no_result.text = txtSearch
        ui_view_no_result.isHidden = true
        if isFromSurvey {
            loadSurveyData()
        }else if isFromReact {
            fetchReactionsDetails()
        }else{
            if isEvent {
                getEventusers()
            }
            else {
                getNeighborhoodUsers()
                AnalyticsLoggerManager.logEvent(name: View_GroupMember_ShowList)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    func loadSurveyData() {
        guard let postId = self.postId, let survey = self.survey else {
            print("Survey information or postId is missing.")
            return
        }

        let completion: (SurveyResponsesListWrapper?, EntourageNetworkError?) -> Void = { [weak self] surveyResponsesListWrapper, error in
            guard let self = self else {
                print("Self was deallocated.")
                return
            }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error retrieving survey responses: \(error)")
                    return
                }
                guard let surveyResponsesList = surveyResponsesListWrapper?.responses, !surveyResponsesList.isEmpty else {
                    print("No survey responses were found or the response list is empty.")
                    return
                }

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
    
    func getNeighborhoodUsers() {
        guard let neighborhood = neighborhood else { return }
        
        NeighborhoodService.getNeighborhoodUsers(neighborhoodId: neighborhood.uid, completion: { [weak self] users, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let users = users {
                    self.users = users
                    // Mise à jour de tableData
                    self.tableData = [.searchCell] // Si tu veux toujours afficher la cellule de recherche
                    self.tableData += users.map { .userCell(user: $0, reactionType: nil) }
                    self.ui_tableview.reloadData()
                } else if let error = error {
                    print("Erreur lors de la récupération des utilisateurs: \(error)")
                    // Gérer l'erreur, par exemple en affichant un message à l'utilisateur
                }
            }
        })
    }

    
    func getEventusers() {
        guard let event = event else { return }
        
        EventService.getEventUsers(eventId: event.uid, completion: { [weak self] users, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur lors de la récupération des utilisateurs de l'événement: \(error)")
                    self.goBack()
                    return
                }
                if let users = users {
                    print("users " , users)
                    self.users = users
                    // Mise à jour de tableData pour refléter les nouveaux utilisateurs
                    self.tableData = [.searchCell] // Inclure la cellule de recherche si nécessaire
                    self.tableData += users.map { .userCell(user: $0, reactionType: nil) } // Pas de type de réaction pour les utilisateurs d'événement
                    self.ui_tableview.reloadData()
                    // Gérer l'affichage de "aucun résultat"
                    self.ui_view_no_result.isHidden = !users.isEmpty
                }
            }
        })
    }

    func searchUser(text: String) {
        usersSearch.removeAll()
        let searchedUsers = users.filter { $0.displayName.lowercased().contains(text.lowercased()) }
        usersSearch.append(contentsOf: searchedUsers)

        // Mise à jour de tableData pour les résultats de recherche
        // En supposant que tu veuilles toujours afficher la cellule de recherche en haut
        tableData = [.searchCell]
        if usersSearch.isEmpty {
            // Afficher "aucun résultat" si nécessaire
            ui_view_no_result.isHidden = false
            // Si tu veux afficher une cellule "Aucun résultat" dans le tableau :
            // tableData.append(.noResultCell) // Assure-toi d'avoir un cas pour cela dans ton énum TableDTO
        } else {
            ui_view_no_result.isHidden = true
            // Ajoute les cellules utilisateur pour les résultats de la recherche à tableData
            tableData += searchedUsers.map { .userCell(user: $0, reactionType: nil) } // Pas de type de réaction pour la recherche
        }

        // Mise à jour de l'UI
        ui_tableview.reloadData()
    }

    func fetchReactionsDetails() {
        guard let postId = self.postId else { return }

        let completion: (CompleteReactionsResponse?, EntourageNetworkError?) -> Void = { [weak self] response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let userReactions = response?.userReactions {
                    // Traite la réponse en stockant les utilisateurs et les réactions
                    self.users = userReactions.map { $0.user }
                    // Réinitialise et remplit reactionTypeList basé sur userReactions
                    self.reactionTypeList = userReactions.map { ReactionType(id: $0.reactionId, key: nil, imageUrl: nil) }

                    // Mise à jour de tableData pour refléter les nouvelles données
                    self.tableData += self.users.enumerated().map { index, user in
                        // Associer chaque utilisateur à son type de réaction pour la construction de la cellule
                        .userCell(user: user, reactionType: self.reactionTypeList[safe: index])
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


    func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        do {
            let reactions = try JSONDecoder().decode([ReactionType].self, from: reactionsData)
            return reactions
        } catch {
            print("Erreur de décodage des réactions : \(error)")
            return nil
        }
    }
    func loadStoredReactionTypes() {
        reactionsTypes = getStoredReactionTypes() ?? []
    }
}

//MARK: - Tableview Datasource/delegate -
extension NeighBorhoodEventListUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Masquer les séparateurs pour les premières lignes, par exemple pour les lignes 0 à 2
        if indexPath.row < 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            // Ajouter le séparateur par défaut ou personnalisé pour les autres lignes
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableData[indexPath.row]{
            
        case .searchCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            let title = isEvent ? "event_userInput_search".localized : "neighborhood_userInput_search".localized
            cell.populateCell(delegate: self, isSearch:isSearch,placeceholder:title, isCellUserSearch: true)
            return cell
        case .userCell(let _user,let _reactionType):
            print("user group role " , _user.groupRole)
            var position = indexPath.row - 1
            if isFromReact || isFromSurvey {
                position = position + 1
            }
            let isMe = _user.sid == UserDefaults.currentUser?.sid
            let isOrganiser = _user.groupRole == "organizer"
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! NeighborhoodUserCell
            cell.populateCell(isMe:isMe, username: _user.displayName, role: _user.getCommunityRoleWithPartnerFormated(), imageUrl: _user.avatarURL, showBtMessage: true,delegate: self,position: position, reactionType: _reactionType, isConfirmed: _user.confirmedAt != nil, isOrganizer: isOrganiser, isCreator: isMe)
            cell.hideSeparatorBarIfIsVote(isVote: self.isFromSurvey)
            return cell
        
        case .surveySection(let title, let voteCount):
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "SectionOptionNameCell") as? SectionOptionNameCell{
                cell.selectionStyle = .none
                cell.configure(title: title, countVote: voteCount)
                return cell
            }
        case .questionCell(let title):

            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "QuestionSurveyVoteCell") as? QuestionSurveyVoteCell{
                cell.selectionStyle = .none
                cell.configure(title: title)
                return cell
            }
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_search", for: indexPath) as! NeighborhoodHomeSearchCell
            let title = isEvent ? "event_userInput_search".localized : "neighborhood_userInput_search".localized
            cell.populateCell(delegate: self, isSearch:isSearch,placeceholder:title, isCellUserSearch: true)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData[indexPath.row]{
            
        case .searchCell:
            return
        case .userCell(let _user, let _reactionType):
            var user:UserLightNeighborhood?
            if isSearch {
                if !isEvent {
                    AnalyticsLoggerManager.logEvent(name: Action_GroupMember_Search_SeeResult)
                }
                if self.usersSearch.count < indexPath.row{
                    user = self.usersSearch[indexPath.row]
                }
            }
            else {
                if !isEvent {
                    AnalyticsLoggerManager.logEvent(name: Action_GroupMember_See1Member)
                }
                if self.usersSearch.count < indexPath.row{
                    
                }
            }
            user = _user
            if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
                
                if let _user = user {
                    profileVC.userIdToDisplay = "\(_user.sid)"
                }
                
                profileVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(profileVC, animated: true)
            }
        case .surveySection(title: let title, voteCount: let voteCount):
            return
        case .questionCell(title: let title):
            return
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
        // Assurez-vous que la position est dans les limites de tableData
        guard position < tableData.count else { return }

        // Trouver l'utilisateur à partir de tableData
        if case let .userCell(user, _) = tableData[position] {
            if !isEvent {
                AnalyticsLoggerManager.logEvent(name: Action_GroupMember_WriteTo1Member)
            }
            
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
    func didTapEvent() {
        //Nothing yet
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
