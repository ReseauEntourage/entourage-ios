import UIKit
import SwiftUI

class ConversationsMainHomeViewController: UIViewController {
    
    private var hostingController: UIHostingController<ConversationsMainHomeView>?
    private var swiftUIView: ConversationsMainHomeView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwiftUIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // Optionally trigger refresh here if needed, but the view model does it on init
        if let vm = hostingController?.rootView.viewModel {
            vm.loadConversations(reset: true)
        }
    }
    
    private func setupSwiftUIView() {
        var view = ConversationsMainHomeView()

        view.onShowConversation = { [weak self] dto in
            self?.handleShowConversation(dto: dto)
        }

        view.onShowProfile = { [weak self] userId in
            self?.handleShowProfile(userId: userId)
        }

        view.onShowWebUrl = { [weak self] url in
            guard let self = self else { return }
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
        }

        view.onRequestNotifications = { [weak self] in
            self?.handleNotificationRequest()
        }

        let host = UIHostingController(rootView: view)
        addChild(host)
        host.view.frame = self.view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(host.view)
        host.didMove(toParent: self)

        self.hostingController = host
        self.swiftUIView = view
    }

    private func handleShowConversation(dto: ConversationMainDTO) {
        switch dto {
        case .conversation(let conversation):
            if conversation.type == "small_talk" {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                    vc.type = "small_talk"
                    vc.setupFromSmallTalk(smallTalkId: conversation.uid, title: conversation.title, delegate: self)
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
                        selectedIndexPath: nil
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
        default:
            break
        }
    }

    private func handleShowProfile(userId: Int) {
        if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
            .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
            profileVC.userIdToDisplay = "\(userId)"
            profileVC.modalPresentationStyle = .fullScreen
            self.present(profileVC, animated: true)
        }
    }

    private func handleNotificationRequest() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.hostingController?.rootView.viewModel.notificationsDisabled = false
                    self.hostingController?.rootView.viewModel.loadConversations(reset: true)
                } else {
                    let sb = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "paramsNotifsVC")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ConversationsMainHomeViewController: UpdateUnreadCountDelegate {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?) {
        hostingController?.rootView.viewModel.updateUnreadCount(conversationId: conversationId)
    }
}
