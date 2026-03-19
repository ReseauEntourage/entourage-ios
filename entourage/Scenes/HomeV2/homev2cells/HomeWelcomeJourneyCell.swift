import UIKit
import SwiftUI

class HomeWelcomeJourneyCell: UITableViewCell {

    static let identifier = "HomeWelcomeJourneyCell"
    private var hostingController: UIHostingController<HomeWelcomeJourneyView>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor(named: "white_orange_home")
        self.selectionStyle = .none
    }

    func configure(viewModel: WelcomeJourneyViewModel, parentViewController: UIViewController) {
        if let currentHostingController = hostingController {
            currentHostingController.rootView = HomeWelcomeJourneyView(viewModel: viewModel)
            currentHostingController.view.setNeedsLayout()
        } else {
            let swiftUIView = HomeWelcomeJourneyView(viewModel: viewModel)
            let newHostingController = UIHostingController(rootView: swiftUIView)

            parentViewController.addChild(newHostingController)
            contentView.addSubview(newHostingController.view)

            newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            newHostingController.view.backgroundColor = .clear

            NSLayoutConstraint.activate([
                newHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                newHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                newHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                newHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            newHostingController.didMove(toParent: parentViewController)
            self.hostingController = newHostingController
        }
    }
}
