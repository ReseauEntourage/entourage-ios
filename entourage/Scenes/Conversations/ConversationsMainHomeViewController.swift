import UIKit
import SwiftUI
import SVProgressHUD

enum ConversationMainDTO {
    case notificationRequest
    case bonnesOndesCard
    case sectionLabel(text: String)
    case conversation(conversation: Conversation, isDedicatedContact: Bool)
    case smalltalk(smallTalk: SmallTalk)
}

class ConversationsMainHomeViewController: UIViewController {
    
    // MARK: - UI Outlets
    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_view_selector: UIView!
    
    // MARK: - Properties
    var dataSource = [ConversationMainDTO]()
    var notificationsDisabled: Bool = false
    /// Empty = no filter (all conversations). Values: "Conversation", "Outing", "Smalltalk" — EN-9487.
    var selectedTypes: Set<String> = []
    var isLastPage = false

    var currentPage = 1
    var isFetching = false
    let perPage = 25
    /// Larger page used when merging results from several types client-side (no server-side multi-type support).
    let multiTypePerPage = 50

    var maxViewHeight: CGFloat = 109
    var minViewHeight: CGFloat = 70

    /// Fetched once per screen lifetime — same source as the Home "contact dédié" card — EN-9487.
    private var moderator: HomeModerator?
    /// True once fetchModeratorIdThenLoad()'s network call has returned (success or nil) — EN-9487.
    private var hasResolvedModeratorId = false

    private var headerHostingController: UIHostingController<ConversationsHeaderBarView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableview.dataSource = self
        ui_tableview.delegate = self

        ui_tableview.register(UINib(nibName: "ConversationNotifAskViewCell", bundle: nil), forCellReuseIdentifier: "ConversationNotifAskViewCell")
        ui_tableview.register(ConversationListMainSwiftUICell.self, forCellReuseIdentifier: ConversationListMainSwiftUICell.identifier)
        ui_tableview.register(ConversationSectionLabelCell.self, forCellReuseIdentifier: ConversationSectionLabelCell.identifier)
        ui_tableview.register(BonnesOndesCardCell.self, forCellReuseIdentifier: BonnesOndesCardCell.identifier)

        setupViews()
        setupHeaderBar()
        checkNotificationStatus()
        fetchModeratorIdThenLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateFilterSmallTalk), name: NSNotification.Name(kNotificationMessagesUpdateSmallTalkFilter), object: nil)
    }

    /// SwiftUI title + round "sliders" filter button, hosted over the straight orange header — EN-9490.
    private func setupHeaderBar() {
        let host = UIHostingController(rootView: headerBarView())
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            host.view.heightAnchor.constraint(equalToConstant: 52)
        ])

        headerHostingController = host
    }

    private func headerBarView() -> ConversationsHeaderBarView {
        ConversationsHeaderBarView(filterActive: !selectedTypes.isEmpty, onFilterTap: { [weak self] in
            self?.onFilterTap()
        })
    }

    private func refreshHeaderBar() {
        headerHostingController?.rootView = headerBarView()
    }

    @objc private func updateFilterSmallTalk() {
        self.selectedTypes = ["Smalltalk"]
        self.updateFilterBadge()
        self.loadConversations(reset: true)
    }

    private func fetchModeratorIdThenLoad() {
        HomeService.getUserHome { [weak self] userHome, _ in
            self?.moderator = userHome?.moderator
            self?.hasResolvedModeratorId = true
            self?.loadConversations(reset: true)
        }
    }

    private func updateFilterBadge() {
        refreshHeaderBar()
    }

    private func onFilterTap() {
        let modal = ConversationFilterModalViewController(
            initialSelection: selectedTypes,
            onApply: { [weak self] newSelection in
                self?.selectedTypes = newSelection
                self?.updateFilterBadge()
                self?.loadConversations(reset: true)
            },
            onReset: { [weak self] in
                self?.selectedTypes = []
                self?.updateFilterBadge()
                self?.loadConversations(reset: true)
            }
        )
        present(modal, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Skip the very first call: it would race fetchModeratorIdThenLoad() and load the list
        // before moderatorUserId is known, silently dropping the pinned contact — EN-9487.
        guard hasResolvedModeratorId else { return }
        loadConversations(reset: true)
    }

    func setupViews() {
        ui_tableview.contentInset = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)

        ui_view_selector.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_view_selector.layer.maskedCorners = CACornerMask.radiusTopOnly()

        ui_label_title.isHidden = true
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsDisabled = settings.authorizationStatus != .authorized
                self.loadDTO(conversations: [], reset: true)
            }
        }
    }
    
    func loadConversations(reset: Bool) {
        guard !isFetching else { return }
        isFetching = true

        if reset {
            currentPage = 1
            isLastPage = false
        }

        SVProgressHUD.show()

        if selectedTypes.count > 1 {
            // Plusieurs types sélectionnés : l'API ne supporte qu'un seul `type=` à la fois,
            // on merge donc côté client (pagination simplifiée à la 1ère page pour ce cas).
            loadMultipleTypes(reset: reset)
            return
        }

        let onlyType = selectedTypes.first

        // 1️⃣ Si "Bonnes ondes" est le seul filtre actif, on utilise l’ancien service
        if onlyType == "Smalltalk" {
            SmallTalkService.listSmallTalks { smallTalks, error in
                SVProgressHUD.dismiss()
                self.isFetching = false
                guard let smallTalks = smallTalks else { return }
                self.loadDTO(smallTalks: smallTalks, reset: reset)
            }
            return
        }

        // 2️⃣ Sinon (aucun filtre, ou un seul filtre "Conversation"/"Outing"), le nouvel endpoint memberships
        MessagingService.getConversationMemberships(type: onlyType,
                                                   page: currentPage,
                                                   per: perPage) { memberships, error in
            SVProgressHUD.dismiss()
            self.isFetching = false
            guard let memberships = memberships else { return }

            self.isLastPage = memberships.count < self.perPage

            let conversations = memberships.map { self.conversation(from: $0) }
            self.loadDTO(conversations: conversations, reset: reset)
            self.currentPage += 1
        }
    }

    /// Fetches 2-3 selected types in parallel and merges the results, most recent message first.
    private func loadMultipleTypes(reset: Bool) {
        isLastPage = true // pas de pagination pour la vue fusionnée multi-types
        let group = DispatchGroup()
        var mergedConversations: [Conversation] = []
        var mergedSmallTalks: [SmallTalk] = []
        let lock = NSLock()

        for type in selectedTypes {
            group.enter()
            if type == "Smalltalk" {
                SmallTalkService.listSmallTalks { smallTalks, _ in
                    lock.lock(); mergedSmallTalks.append(contentsOf: smallTalks ?? []); lock.unlock()
                    group.leave()
                }
            } else {
                MessagingService.getConversationMemberships(type: type, page: 1, per: multiTypePerPage) { memberships, _ in
                    let conversations = (memberships ?? []).map { self.conversation(from: $0) }
                    lock.lock(); mergedConversations.append(contentsOf: conversations); lock.unlock()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            SVProgressHUD.dismiss()
            self.isFetching = false

            let sortedConversations = mergedConversations.sorted {
                self.lastMessageDate($0) > self.lastMessageDate($1)
            }
            self.loadDTO(conversations: sortedConversations, reset: reset)
            if !mergedSmallTalks.isEmpty {
                self.loadDTO(smallTalks: mergedSmallTalks, reset: false)
            }
        }
    }

    private func lastMessageDate(_ conversation: Conversation) -> Date {
        guard let dateStr = conversation.lastMessage?.dateStr else { return .distantPast }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.date(from: dateStr) ?? .distantPast
    }

    private func conversation(from membership: ConversationMembership) -> Conversation {
        var conv = Conversation()
        conv.uid = membership.joinableId ?? 0

        conv.type = {
            switch membership.joinableType?.lowercased() {
            case "outing":
                return "outing"
            case "conversation":
                return "private"
            case "smalltalk":
                return "small_talk"
            default:
                return "group"
            }
        }()

        // Formatage de la date ISO de l'événement (si présente)
        let formattedDate: String? = {
            guard let subname = membership.subname else { return nil }
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = isoFormatter.date(from: subname) {
                return Utils.formatEventDateShort(date: date)
            }
            return subname
        }()

        conv.title = membership.name ?? ""
        conv.subname = formattedDate
        
        // CORRECTION DE LA DATE DU DERNIER MESSAGE :
        // membership.lastChatMessageDate contient désormais la bonne chaîne ISO reçue de l'API
        if let text = membership.lastChatMessageText {
            conv.lastMessage = LastMessage(text: text, dateStr: membership.lastChatMessageDate)
        } else if let imageUrl = membership.lastChatMessageImageUrl, !imageUrl.isEmpty {
            conv.lastMessage = LastMessage(text: nil, dateStr: membership.lastChatMessageDate)
        } else if let dateStr = membership.lastChatMessageDate {
            conv.lastMessage = LastMessage(text: nil, dateStr: dateStr)
        }
        
        conv.numberUnreadMessages = membership.numberOfUnreadMessages
        conv.members_count = membership.numberOfPeople
        conv.imageUrl = membership.imageUrl
        conv.lastChatMessageImageUrl = membership.lastChatMessageImageUrl

        // RÈGLE : s'il n'y a qu'UNE personne dans la conv -> c'est toi seul => "Vous"
        if (membership.numberOfPeople ?? 0) <= 1 {
            conv.title = "Vous"
        }

        return conv
    }

    private func appendHeaderRows() {
        if notificationsDisabled {
            dataSource.append(.notificationRequest)
        }
        dataSource.append(.bonnesOndesCard)
        dataSource.append(.sectionLabel(text: "conversation_your_conversations".localized))
    }

    /// Pins the dedicated contact at the top, same source as the Home "contact dédié" card — EN-9487.
    /// Uses its real conversation content when one already exists, otherwise a placeholder invite row.
    private func pinModeratorConversation(in conversations: [Conversation]) -> [Conversation] {
        guard let moderator = moderator, let moderatorId = moderator.id else {
            return conversations
        }

        var result = conversations
        // getConversationMemberships doesn't return the interlocutor's id, only their name/avatar —
        // match on display name since that's the only moderator field the membership payload mirrors.
        if let index = result.firstIndex(where: { $0.type == "private" && $0.title == moderator.displayName }) {
            let moderatorConv = result.remove(at: index)
            dataSource.append(.conversation(conversation: moderatorConv, isDedicatedContact: true))
        } else {
            dataSource.append(.conversation(conversation: placeholderConversation(for: moderator), isDedicatedContact: true))
        }
        return result
    }

    private func placeholderConversation(for moderator: HomeModerator) -> Conversation {
        var conversation = Conversation()
        conversation.uid = moderator.id ?? 0
        conversation.type = "private"
        conversation.title = moderator.displayName
        conversation.user = MemberConversation(uid: moderator.id ?? 0, displayName: moderator.displayName, imageUrl: moderator.imgUrl)
        conversation.lastMessage = LastMessage(text: "home_v2_moderator_subtitle".localized, dateStr: nil)
        conversation.numberUnreadMessages = 0
        return conversation
    }

    /// Opens the dedicated contact's thread the same way the Home "contact dédié" card does —
    /// createOrGetConversation always resolves to the right thread, whether it already exists or not.
    private func openDedicatedContactConversation() {
        guard let moderatorId = moderator?.id else { return }

        SVProgressHUD.show()
        MessagingService.createOrGetConversation(userId: String(moderatorId)) { [weak self] conversation, _ in
            SVProgressHUD.dismiss()
            guard let self = self, let conversation = conversation else { return }

            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                vc.type = conversation.type ?? "private"
                vc.setupFromOtherVC(
                    conversationId: conversation.uid,
                    title: conversation.title,
                    isOneToOne: true,
                    delegate: self
                )
                self.present(vc, animated: true)
            }
        }
    }

    func loadDTO(conversations: [Conversation], reset: Bool) {
        if reset {
            dataSource.removeAll()
            appendHeaderRows()
        }

        let startIndex = dataSource.count
        let remaining = reset ? pinModeratorConversation(in: conversations) : conversations
        let newItems = remaining.map { ConversationMainDTO.conversation(conversation: $0, isDedicatedContact: false) }
        dataSource.append(contentsOf: newItems)

        DispatchQueue.main.async {
            if reset {
                self.ui_tableview.reloadData()
            } else {
                let indexPaths = (startIndex..<self.dataSource.count).map { IndexPath(row: $0, section: 0) }
                self.ui_tableview.insertRows(at: indexPaths, with: .fade)
            }
        }
    }

    func loadDTO(smallTalks: [SmallTalk], reset: Bool) {
        if reset {
            dataSource.removeAll()
            appendHeaderRows()
        }

        let startIndex = dataSource.count
        let newItems = smallTalks.map { ConversationMainDTO.smalltalk(smallTalk: $0) }
        dataSource.append(contentsOf: newItems)

        DispatchQueue.main.async {
            if reset {
                self.ui_tableview.reloadData()
            } else {
                let indexPaths = (startIndex..<self.dataSource.count).map { IndexPath(row: $0, section: 0) }
                self.ui_tableview.insertRows(at: indexPaths, with: .fade)
            }
        }
    }
}

// MARK: - Table View
extension ConversationsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dto = dataSource[indexPath.row]

        switch dto {
        case .notificationRequest:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationNotifAskViewCell", for: indexPath) as! ConversationNotifAskViewCell
            cell.configureText()
            cell.selectionStyle = .none
            return cell

        case .conversation(let conversation, let isDedicatedContact):
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListMainSwiftUICell.identifier, for: indexPath) as! ConversationListMainSwiftUICell
            let currentUserId = UserDefaults.currentUser?.sid
            cell.configure(conversation: conversation, currentUserId: currentUserId, isSmallTalk: false, isDedicatedContact: isDedicatedContact)
            return cell

        case .smalltalk(let smallTalk):
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListMainSwiftUICell.identifier, for: indexPath) as! ConversationListMainSwiftUICell
            var conversation = Conversation(from: smallTalk)

            let currentUserId = UserDefaults.currentUser?.sid
            let filteredMembers = conversation.members?.filter { $0.uid != currentUserId } ?? []

            if filteredMembers.isEmpty {
                conversation.title = "Vous"
            } else {
                let memberNames = filteredMembers.compactMap { $0.username }.joined(separator: " • ")
                conversation.title = memberNames
            }

            cell.configure(conversation: conversation, currentUserId: currentUserId, isSmallTalk: true)
            return cell

        case .bonnesOndesCard:
            let cell = tableView.dequeueReusableCell(withIdentifier: BonnesOndesCardCell.identifier, for: indexPath) as! BonnesOndesCardCell
            cell.onDiscuterTap = { [weak self] in
                self?.presentSmallTalkFunnel()
            }
            cell.selectionStyle = .none
            return cell

        case .sectionLabel(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationSectionLabelCell.identifier, for: indexPath) as! ConversationSectionLabelCell
            cell.configure(text: text)
            cell.selectionStyle = .none
            return cell
        }
    }

    private func presentSmallTalkFunnel() {
        AnalyticsLoggerManager.logEvent(name: "click_bonnes_ondes_start_discussion")
        let sb = UIStoryboard(name: "SmallTalk", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else { return }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dto = dataSource[indexPath.row]

        switch dto {
        case .bonnesOndesCard, .sectionLabel:
            return

        case .notificationRequest:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.notificationsDisabled = false
                        self.loadConversations(reset: true)
                    } else {
                        let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "paramsNotifsVC")
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            return

        case .conversation(let conversation, let isDedicatedContact):
            if isDedicatedContact {
                openDedicatedContactConversation()
                return
            }
            if conversation.type == "small_talk" {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.type = "small_talk"
                    vc.setupFromSmallTalk(
                        smallTalkId: conversation.uid,
                        title: conversation.title,
                        delegate: self
                    )
                    present(vc, animated: true)
                }
            } else {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.type = conversation.type ?? ""
                    vc.setupFromOtherVC(
                        conversationId: conversation.uid,
                        title: conversation.title,
                        isOneToOne: conversation.isOneToOne(),
                        conversation: conversation,
                        delegate: self,
                        selectedIndexPath: indexPath
                    )
                    present(vc, animated: true)
                }
            }
        case .smalltalk(let smallTalk):
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                vc.type = "small_talk"
                vc.setupFromSmallTalk(smallTalkId: smallTalk.id, title: smallTalk.name ?? "", delegate: self)
                present(vc, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.row] {
        case .bonnesOndesCard, .sectionLabel:
            return UITableView.automaticDimension
        default:
            return 75
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.row] {
        case .bonnesOndesCard:
            return 160
        case .sectionLabel:
            return 40
        default:
            return 75
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 && !isLastPage {
            loadConversations(reset: false)
        }
    }
}

// MARK: - ConversationListMainCellDelegate
extension ConversationsMainHomeViewController: ConversationListMainCellDelegate {
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }

    func showUserDetail(_ position: Int) {
        if case let .conversation(conversation, _) = dataSource[position] {
            guard let userId = conversation.user?.uid else { return }

            presentOtherUserProfile(userId: "\(userId)")
        }
    }
}

// MARK: - UpdateUnreadCountDelegate
extension ConversationsMainHomeViewController: UpdateUnreadCountDelegate {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?) {
        guard let currentIndexPathSelected = currentIndexPathSelected else { return }

        if case var .conversation(conversation, isDedicatedContact) = dataSource[currentIndexPathSelected.row] {
            conversation.numberUnreadMessages = 0
            dataSource[currentIndexPathSelected.row] = .conversation(conversation: conversation, isDedicatedContact: isDedicatedContact)
        }

        DispatchQueue.main.async {
            if self.ui_tableview.numberOfRows(inSection: currentIndexPathSelected.section) > currentIndexPathSelected.row {
                self.ui_tableview.reloadRows(at: [currentIndexPathSelected], with: .none)
            } else {
                self.ui_tableview.reloadData()
            }
        }
    }
}
