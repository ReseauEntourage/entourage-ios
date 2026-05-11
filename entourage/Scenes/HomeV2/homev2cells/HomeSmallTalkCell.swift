import UIKit
import SwiftUI

class HomeSmallTalkCell: UITableViewCell {
    weak var parentViewController: UIViewController?

    class var identifier: String {
        return String(describing: self)
    }

    private var hostingController: UIHostingController<HomeSmallTalkCardView>?

    // Default state
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
        let swiftUIView = HomeSmallTalkCardView(state: state, actionStart: { [weak self] in
            self?.onActionStart()
        }, actionView: { [weak self] in
            self?.onActionView()
        })

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
        let swiftUIView = HomeSmallTalkCardView(state: state, actionStart: { [weak self] in
            self?.onActionStart()
        }, actionView: { [weak self] in
            self?.onActionView()
        })
        self.hostingController?.rootView = swiftUIView
    }

    func configure(with userRequests: [UserSmallTalkRequest]) {
        let matchedRequests = userRequests.filter { $0.smalltalk != nil }
        let pendingRequests = userRequests.filter { $0.smalltalk == nil }

        let activeCount = matchedRequests.count
        let pendingCount = pendingRequests.count

        if activeCount == 0 {
            if pendingCount > 0 {
                self.state = .pending(count: pendingCount)
            } else {
                self.state = .initial
            }
        } else {
            // Get avatars
            var avatars = [String]()
            var unreadTotal = 0
            
            for request in matchedRequests {
                if let smalltalk = request.smalltalk {
                    // Try to find the first member that is not the current user
                    let members = smalltalk.members
                    var filteredMembers = members
                    if let currentSid = UserDefaults.currentUser?.sid {
                        filteredMembers.removeAll(where: { $0.id == currentSid })
                    }

                    if let firstAvatar = filteredMembers.first(where: { $0.avatar_url != nil })?.avatar_url {
                        avatars.append(firstAvatar)
                    } else if let firstMember = filteredMembers.first {
                        // placeholder if needed, although AsyncImage handles empty/invalid url with placeholder
                    }
                }

                if let unread = request.number_of_unread_messages {
                    unreadTotal += unread
                }
            }
            
            self.state = .active(activeCount: activeCount, pendingCount: pendingCount, totalUnread: unreadTotal, avatars: avatars)
        }
    }

    private func onActionStart() {
        AnalyticsLoggerManager.logEvent(name: "click_bonnes_ondes_start_discussion")
        let storyboard = UIStoryboard(name: "SmallTalk", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        vc.modalPresentationStyle = .fullScreen
        parentViewController?.present(vc, animated: true)
    }

    private func onActionView() {
        AnalyticsLoggerManager.logEvent(name: "click_bonnes_ondes_view_messages")
        // Switch to the messages tab and apply smalltalk filter
        NotificationCenter.default.post(name: NSNotification.Name(kNotificationMessagesUpdateSmallTalkFilter), object: nil)

        if let tabController = self.parentViewController?.tabBarController as? MainTabbarViewController {
            tabController.selectedIndex = 2
        }
    }
}
