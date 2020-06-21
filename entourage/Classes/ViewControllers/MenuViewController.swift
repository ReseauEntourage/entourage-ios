//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {

    private let items: [MenuItem] = [
        .profile("AMS"),
        .header(L10n.menuFirstStep),
        .secondary(.regular(L10n.menuScb), addSeparator: true),
        .secondary(.regular(L10n.menuEntourageActions)),
        .spacing(50),
        .header(L10n.menuCommit),
        .main(L10n.menuMakeDonation),
        .secondary(.regular(L10n.menuJoin), addSeparator: true),
        .secondary(.regular("Rejoindre l'équipe")),
        .spacing(50),
        .header("📣 PARTAGER ENTOURAGE"),
//        .share("Répandez la solidarité autour de vous !"),
        .secondary(.regular("Répandez la solidarité autour de vous !")),
        .spacing(50),
        .secondary(.heavy(L10n.menuAbout)),
        .spacing(50),
        .secondary(.regular(L10n.menuDisconnectTitle), icon: Asset.logout.image),
//        .social
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

    private func convertItem(_ item: MenuItem) -> UIView {
        switch item {
        case .profile(let name):
            return MenuProfileItemView(name: name)
        case .spacing(let value):
            return createView(withHeight: value)
        case .header(let text):
            return MenuItemView.header(text: text)
        case .secondary(let title, let icon, let addSeparator):
            return MenuItemView.secondary(title: title, icon: icon, addSeparator: addSeparator)
        case .main(let text):
            return MenuItemView.main(text: text)
        }
    }
}
