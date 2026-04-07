import UIKit
import SwiftUI

class WelcomeEventsListViewController: UIViewController {
    var eventType: WelcomeEventType = .webinar

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = WelcomeEventsListViewModel(type: eventType)
        let swiftUIView = WelcomeEventsListView(viewModel: viewModel, onBack: { [weak self] in
            self?.dismiss(animated: true)
        }, onEventTapped: { [weak self] event in
            let storyboard = UIStoryboard(name: StoryboardName.event, bundle: nil)
            
            if let navVc = storyboard.instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController,
               let vc = navVc.topViewController as? EventDetailFeedViewController {
                vc.eventId = event.uid
                navVc.modalPresentationStyle = .fullScreen
                self?.present(navVc, animated: true)
            }
        })

        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
