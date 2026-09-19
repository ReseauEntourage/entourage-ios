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
            // Route to Event Detail
            let storyboard = UIStoryboard(name: StoryboardName.event, bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "eventDetailFeed") as? EventDetailFeedViewController {
                vc.eventId = event.uid
                vc.isFromMyEvent = true
                self?.present(vc, animated: true)
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
