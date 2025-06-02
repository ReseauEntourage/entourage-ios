import UIKit
import IHProgressHUD

enum ConversationMainDTO {
    case notificationRequest
    case conversation(conversation: Conversation)
    case filter(filter: String)
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
    var selectedFilter: String = "event_conv_filter_all".localized
    var isLastPage = false

    var currentPage = 1
    var isFetching = false
    let perPage = 25

    var maxViewHeight: CGFloat = 109
    var minViewHeight: CGFloat = 70

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_tableview.register(UINib(nibName: "ConversationNotifAskViewCell", bundle: nil), forCellReuseIdentifier: "ConversationNotifAskViewCell")
        ui_tableview.register(UINib(nibName: "FilterDiscussionCell", bundle: nil), forCellReuseIdentifier: "FilterDiscussionCell")

        setupViews()
        checkNotificationStatus()
        loadConversations(reset: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConversations(reset: true)
    }

    func setupViews() {
        ui_tableview.contentInset = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)

        ui_view_selector.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_view_selector.layer.maskedCorners = CACornerMask.radiusTopOnly()

        ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: 23)
        ui_label_title.text = "Messages_title".localized
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
        if isFetching { return }
        isFetching = true

        if reset {
            currentPage = 1
            isLastPage = false
        }

        IHProgressHUD.show()

        if selectedFilter == "event_conv_filter_smalltalks".localized {
            self.isLastPage = true
            SmallTalkService.listSmallTalks { smallTalks, error in
                IHProgressHUD.dismiss()
                self.isFetching = false
                guard let smallTalks = smallTalks else { return }
                self.loadDTO(smallTalks: smallTalks, reset: reset)
            }
        } else {
            let fetchMethod: (Int, Int, @escaping ([Conversation]?, EntourageNetworkError?) -> Void) -> Void

            switch selectedFilter {
            case "event_conv_filter_discussions".localized:
                fetchMethod = MessagingService.getPrivateConversations
            case "event_conv_filter_events".localized:
                fetchMethod = MessagingService.getOutingConversations
            default:
                fetchMethod = MessagingService.getAllConversations
            }

            fetchMethod(currentPage, perPage) { conversations, error in
                IHProgressHUD.dismiss()
                self.isFetching = false
                guard let conversations = conversations else { return }

                self.isLastPage = conversations.count < self.perPage
                self.loadDTO(conversations: conversations, reset: reset)
                self.currentPage += 1
            }
        }
    }

    func loadDTO(conversations: [Conversation], reset: Bool) {
        if reset {
            dataSource.removeAll()
            dataSource.append(.filter(filter: ""))
            if notificationsDisabled {
                dataSource.append(.notificationRequest)
            }
        }

        let startIndex = dataSource.count
        let newItems = conversations.map { ConversationMainDTO.conversation(conversation: $0) }
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
            dataSource.append(.filter(filter: ""))
            if notificationsDisabled {
                dataSource.append(.notificationRequest)
            }
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

        case .conversation(let conversation):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! ConversationListMainCell
            cell.populateCell(message: conversation, delegate: self, position: indexPath.row)
            return cell

        case .smalltalk(let smallTalk):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! ConversationListMainCell
            var conversation = Conversation(from: smallTalk)
            let memberNames = conversation.members?.compactMap { $0.username }.joined(separator: " • ") ?? ""
            conversation.title = memberNames
            cell.populateCell(message: conversation, delegate: self, position: indexPath.row)
            return cell

        case .filter(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterDiscussionCell", for: indexPath) as! FilterDiscussionCell
            let filters = [
                "event_conv_filter_all".localized,
                "event_conv_filter_discussions".localized,
                "event_conv_filter_events".localized,
                "event_conv_filter_smalltalks".localized
            ]
            cell.configure(filters: filters, selectedFilter: selectedFilter)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dto = dataSource[indexPath.row]

        switch dto {
        case .notificationRequest, .filter(_):
            return

        case .conversation(let conversation):
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                vc.type = conversation.type ?? ""
                vc.setupFromOtherVC(conversationId: conversation.uid, title: conversation.title, isOneToOne: conversation.isOneToOne(), conversation: conversation, delegate: self, selectedIndexPath: indexPath)
                present(vc, animated: true)
            }

        case .smalltalk(let smallTalk):
            if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                vc.type = "small_talk"
                vc.setupFromSmallTalk(smallTalkId: smallTalk.id, title: smallTalk.name ?? "", delegate: self)
                present(vc, animated: true)
            }
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
        if case let .conversation(conversation) = dataSource[position] {
            guard let userId = conversation.user?.uid else { return }

            if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
                profileVC.userIdToDisplay = "\(userId)"
                profileVC.modalPresentationStyle = .fullScreen
                self.present(profileVC, animated: true)
            }
        }
    }
}

// MARK: - UpdateUnreadCountDelegate
extension ConversationsMainHomeViewController: UpdateUnreadCountDelegate {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?) {
        guard let currentIndexPathSelected = currentIndexPathSelected else { return }

        if case var .conversation(conversation) = dataSource[currentIndexPathSelected.row] {
            conversation.numberUnreadMessages = 0
            dataSource[currentIndexPathSelected.row] = .conversation(conversation: conversation)
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

// MARK: - FilterDiscussionCellDelegate
extension ConversationsMainHomeViewController: FilterDiscussionCellDelegate {
    func onFilterClick(filter: String) {
        self.selectedFilter = filter
        loadConversations(reset: true)
    }
}
