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
            currentHostingController.view.invalidateIntrinsicContentSize()
            currentHostingController.view.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        } else {
            let swiftUIView = HomeWelcomeJourneyView(viewModel: viewModel)
            let newHostingController = UIHostingController(rootView: swiftUIView)

            parentViewController.addChild(newHostingController)
            contentView.addSubview(newHostingController.view)

            newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            newHostingController.view.backgroundColor = .clear

            if #available(iOS 16.0, *) {
                newHostingController.sizingOptions = .intrinsicContentSize
            }

            let topConstraint = newHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor)
            topConstraint.priority = .defaultHigh // lower priority to prevent conflict with internal sizing
            let bottomConstraint = newHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            bottomConstraint.priority = .defaultHigh

            NSLayoutConstraint.activate([
                topConstraint,
                bottomConstraint,
                newHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                newHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            newHostingController.didMove(toParent: parentViewController)
            newHostingController.view.layoutIfNeeded()
            self.contentView.layoutIfNeeded()
            self.hostingController = newHostingController
        }
    }
}
