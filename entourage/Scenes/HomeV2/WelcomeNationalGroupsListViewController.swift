import UIKit
import SwiftUI

class WelcomeNationalGroupsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = WelcomeNationalGroupsListView(onBack: { [weak self] in
            self?.dismiss(animated: true)
        }, onGroupTapped: { group in
            DeepLinkManager.showNeighborhoodDetailUniversalLink(id: "\(group.uid)")
        }, onGroupsTabRequested: { [weak self] in
            guard let self = self else { return }
            let parent = self.presentingViewController as? HomeV2ViewController
            self.dismiss(animated: true) {
                let hasShownSnackbar = UserDefaults.standard.bool(forKey: "hasShownWelcomeNationalGroupSnackbar")
                if !hasShownSnackbar {
                    UserDefaults.standard.set(true, forKey: "hasShownWelcomeNationalGroupSnackbar")
                    if let homeParent = parent {
                        homeParent.showWelcomeNationalGroupSnackbar()
                    } else if let topVC = AppState.getTopViewController() as? HomeV2ViewController {
                        topVC.showWelcomeNationalGroupSnackbar()
                    }
                }
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
