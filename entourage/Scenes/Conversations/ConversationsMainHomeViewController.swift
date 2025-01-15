import UIKit
import IHProgressHUD

class ConversationsMainHomeViewController: UIViewController {

    @IBOutlet weak var ui_image_inside_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_image_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_constraint_bottom_label: NSLayoutConstraint!
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_view_selector: UIView!

    var maxViewHeight: CGFloat = 109
    var minViewHeight: CGFloat = 70
    var messages = [Conversation]()
    var notificationsDisabled: Bool = false // Indicateur pour l'état des notifications

    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableview.dataSource = self
        ui_tableview.delegate = self

        // Enregistrer la cellule personnalisée
        ui_tableview.register(UINib(nibName: "ConversationNotifAskViewCell", bundle: nil), forCellReuseIdentifier: "ConversationNotifAskViewCell")

        setupViews()
        checkNotificationStatus()
        getMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMessages()
    }

    func checkNotificationStatus() {
        // Vérification de l'état des notifications (mock ou logique réelle)
        notificationsDisabled = !UIApplication.shared.isRegisteredForRemoteNotifications
        print("eho " , notificationsDisabled)
    }

    func reloadWithoutNotificationCell() {
        notificationsDisabled = false
        ui_tableview.reloadData()
    }

    func openNotificationDemandViewController() {
        let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NotificationDemandViewController") as? NotificationDemandViewController {
            vc.modalPresentationStyle = .overFullScreen // Optionnel
            vc.comeFromDiscussion = true
            self.present(vc, animated: true, completion: nil)
        } else {
            print("ViewController with identifier 'NotificationDemandViewController' not found")
        }
    }

    func setupViews() {
        ui_view_selector.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_view_selector.layer.maskedCorners = CACornerMask.radiusTopOnly()

        maxViewHeight = ui_view_height_constraint.constant

        self.ui_label_title.font = ApplicationTheme.getFontQuickSandBold(size: 23)
        self.ui_label_title.text = "Messages_title".localized

        ui_tableview.contentInset = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)
        ui_tableview.scrollIndicatorInsets = UIEdgeInsets(top: maxViewHeight, left: 0, bottom: 0, right: 0)
    }

    func getMessages() {
        if IHProgressHUD.isVisible() { return }
        IHProgressHUD.show()

        MessagingService.getAllConversations(currentPage: 1, per: 25) { messages, error in
            IHProgressHUD.dismiss()
            if let messages = messages {
                self.messages = messages
            }
            self.ui_tableview.reloadData()
        }
    }
}

// MARK: - Table View Data Source & Delegate
extension ConversationsMainHomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (notificationsDisabled ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if notificationsDisabled && indexPath.row == 0 {
            // Charger la cellule personnalisée
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationNotifAskViewCell", for: indexPath) as! ConversationNotifAskViewCell
            cell.configureText()
            cell.selectionStyle = .none
            return cell
        }

        // Charger une cellule classique
        let adjustedIndex = notificationsDisabled ? indexPath.row - 1 : indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! ConversationListMainCell
        let message = messages[adjustedIndex]
        cell.populateCell(message: message, delegate: self, position: adjustedIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if notificationsDisabled && indexPath.row == 0 {
            reloadWithoutNotificationCell()
            openNotificationDemandViewController()
            return
        }

        let adjustedIndex = notificationsDisabled ? indexPath.row - 1 : indexPath.row
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
            let conv = messages[adjustedIndex]
            vc.setupFromOtherVC(conversationId: conv.uid, title: conv.title, isOneToOne: conv.isOneToOne(), conversation: conv, delegate: self, selectedIndexPath: indexPath)
            present(vc, animated: true)
        }
    }
}

// MARK: - ConversationListMainCellDelegate
extension ConversationsMainHomeViewController: ConversationListMainCellDelegate {
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }

    func showUserDetail(_ position: Int) {
        let userId: Int? = messages[position].user?.uid
        guard let userId = userId else { return }

        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let homeVC = navVC.topViewController as? UserProfileDetailViewController {
                homeVC.currentUserId = "\(userId)"
                self.present(navVC, animated: true)
            }
        }
    }
}

// MARK: - UpdateUnreadCountDelegate
extension ConversationsMainHomeViewController: UpdateUnreadCountDelegate {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?) {
        guard let currentIndexPathSelected = currentIndexPathSelected else { return }

        messages[currentIndexPathSelected.row].numberUnreadMessages = 0
        self.ui_tableview.reloadRows(at: [currentIndexPathSelected], with: .none)
    }
}
