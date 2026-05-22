import UIKit
import SwiftUI

class ConversationListMainSwiftUICell: UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }

    private var hostingController: UIHostingController<ConversationListMainCellSwiftUI>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }

    func configure(conversation: Conversation, currentUserId: Int?, isSmallTalk: Bool) {
        let swiftUIView = ConversationListMainCellSwiftUI(
            conversation: conversation,
            currentUserId: currentUserId,
            isSmallTalk: isSmallTalk
        )

        if let hostingController = hostingController {
            hostingController.rootView = swiftUIView
        } else {
            let host = UIHostingController(rootView: swiftUIView)
            host.view.translatesAutoresizingMaskIntoConstraints = false
            host.view.backgroundColor = .clear

            contentView.addSubview(host.view)

            NSLayoutConstraint.activate([
                host.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            self.hostingController = host
        }
    }
}
