import UIKit
import SwiftUI

class HomeSmallTalkCell: UITableViewCell {
    weak var parentViewController: UIViewController?

    class var identifier: String {
        return String(describing: self)
    }

    private var hostingController: UIHostingController<HomeSmallTalkCardView>?

    var state: SmallTalkCardState = .initial {
        didSet {
            updateSwiftUIView()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwiftUIView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSwiftUIView()
    }

    private func setupSwiftUIView() {
        let swiftUIView = HomeSmallTalkCardView(
            state: state,
            actionStart: { [weak self] in self?.onActionStart() },
            actionView: { [weak self] in self?.onActionView() }
        )

        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        contentView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        self.hostingController = hostingController
    }

    private func updateSwiftUIView() {
        let swiftUIView = HomeSmallTalkCardView(
            state: state,
            actionStart: { [weak self] in self?.onActionStart() },
            actionView: { [weak self] in self?.onActionView() }
        )
        hostingController?.rootView = swiftUIView
    }

    // MARK: - Configuration avec les requêtes utilisateur
    func configure(with userRequests: [UserSmallTalkRequest]) {
        let matchedRequests = userRequests.filter { $0.smalltalk != nil }
        let pendingRequests = userRequests.filter { $0.smalltalk == nil }

        let activeCount = matchedRequests.count
        let pendingCount = pendingRequests.count
        let totalMatches = activeCount + pendingCount

        if activeCount == 0 {
            // Aucun match actif → afficher l'état initial ou en attente
            if pendingCount > 0 {
                self.state = .pending(count: pendingCount)
            } else {
                self.state = .initial
            }
        } else {
            // Au moins un match actif → état actif
            var avatars = [String]()
            var unreadTotal = 0

            for request in matchedRequests {
                if let smalltalk = request.smalltalk {
                    // Récupérer les membres (exclure l'utilisateur courant)
                    let members = smalltalk.members
                    var filteredMembers = members
                    if let currentSid = UserDefaults.currentUser?.sid {
                        filteredMembers.removeAll(where: { $0.id == currentSid })
                    }

                    // Priorité aux avatars non-placeholder
                    if let firstAvatar = filteredMembers.first(where: { $0.avatar_url != nil })?.avatar_url {
                        avatars.append(firstAvatar)
                    } else if let firstMember = filteredMembers.first {
                        avatars.append(firstMember.avatar_url ?? "placeholder")
                    }
                }

                // Compter les messages non lus
                if let unread = request.number_of_unread_messages {
                    unreadTotal += unread
                }
            }

            // Trier pour mettre les avatars valides en premier
            avatars.sort { $0 != "placeholder" && $1 == "placeholder" }

            // Limiter à 2 avatars max
            if avatars.count > 2 {
                avatars = Array(avatars.prefix(2))
            }

            self.state = .active(
                activeCount: activeCount,
                pendingCount: pendingCount,
                totalUnread: unreadTotal,
                avatars: avatars
            )
        }
    }

    // MARK: - Actions
    private func onActionStart() {
        AnalyticsLoggerManager.logEvent(name: "click_bonnes_ondes_start_discussion")
        let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        vc.modalPresentationStyle = .fullScreen
        parentViewController?.present(vc, animated: true)
    }

    private func onActionView() {
        AnalyticsLoggerManager.logEvent(name: "click_bonnes_ondes_view_messages")
        NotificationCenter.default.post(
            name: NSNotification.Name(kNotificationMessagesUpdateSmallTalkFilter),
            object: nil
        )
        if let tabController = parentViewController?.tabBarController as? MainTabbarViewController {
            tabController.selectedIndex = 2 // Onglet Messages
        }
    }
}
