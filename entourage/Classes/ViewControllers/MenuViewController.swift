//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {

    enum Item {
        case profile(_ name: String)
        case spacing(_ value: CGFloat)
        case header(_ title: String)
        case secondary(_ title: String, addSeparator: Bool = false)
        case main(_ title: String)
    }

    private let items: [Item] = [
        .profile("AMS"),
        .header("👋  FAIRE LE PREMIER PAS "),
        .secondary("Notre guide pour oser la rencontre", addSeparator: true),
        .secondary("Idées d'actions dans l'appli"),
        .spacing(50),
        .header("❤️  S’ENGAGER"),
        .main("Faire un don à Entourage"),
        .secondary("Devenir Ambassadeur bénévole", addSeparator: true),
        .secondary("Rejoindre l'équipe"),
        .spacing(50),
        .header("📣 PARTAGER ENTOURAGE"),
        .secondary("Répandez la solidarité autour de vous !"),
        .spacing(50)
    ]

    private let stackView = UIStackView()

    override func loadView() {
        let view = applyAndReturn(
            UIView(),
            Style.View.greyBackground()
        )

        let scrollView = applyAndReturn(
            UIScrollView(),
            addInSuperview(view)
                <> pinEdgesToSuperview()
        )

        stackView
            |> addInSuperview(scrollView)
            <> pinEdgesToSuperview([.leading(), .trailing(), .top(), .bottom(relation: .lessThanOrEqual)])
            <> constraintWidth(toWidthOf: view)
            <> set(\UIStackView.axis, .vertical)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        items |> map(convertItem >>> { self.stackView.addArrangedSubview($0) })
    }

    private func convertItem(_ item: Item) -> UIView {
        switch item {
        case .profile(let name):
            return MenuProfileItemView(name: name)
        case .spacing(let value):
            return createView(withHeight: value)
        case .header(let title):
            return MenuItemView.header(title: title)
        case .secondary(let title, let addSeparator):
            return MenuItemView.secondary(title: title, addSeparator: addSeparator)
        case .main(let title):
            return MenuItemView.main(title: title)
        }
    }
}
