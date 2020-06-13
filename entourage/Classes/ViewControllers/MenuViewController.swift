//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

enum Style {
    enum View {
        static func greyBackground<V: UIView>() -> (V) -> V {
            set(\V.backgroundColor, UIColor.appPaleGrey())
        }
        static func whiteBackground<V: UIView>() -> (V) -> V {
            set(\V.backgroundColor, UIColor.white)
        }
        static func orangeBackground<V: UIView>() -> (V) -> V {
            set(\V.backgroundColor, UIColor.appOrange())
        }
    }
}

final class MenuViewController: UIViewController {

    enum Item {
        case spacing(_ value: CGFloat)
        case header(_ title: String)
        case regular(_ title: String, addSeparator: Bool = false)
        case main(_ title: String)
    }

    private let items: [Item] = [
        .spacing(200),
        .header("👋  FAIRE LE PREMIER PAS "),
        .regular("Notre guide pour oser la rencontre", addSeparator: true),
        .regular("Idées d'actions dans l'appli"),
        .spacing(50),
        .header("❤️  S’ENGAGER"),
        .main("Faire un don à Entourage"),
        .regular("Devenir Ambassadeur bénévole", addSeparator: true),
        .regular("Rejoindre l'équipe"),
        .spacing(50),
        .header("📣 PARTAGER ENTOURAGE"),
        .regular("Répandez la solidarité autour de vous !"),
        .spacing(50)
    ]

    private let stackView = UIStackView()

    override func loadView() {
        let view = UIView()
            |> Style.View.greyBackground()

        let scrollView = UIScrollView()
            |> addInSuperview(view)
            <> pinEdgesToSuperview()

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
        case .spacing(let value):
            return createView(withHeight: value)

        case .header(let title):
            return MenuItemView(withSeparator: false)
                |> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .medium))
                <> set(\MenuItemView.textColor, UIColor.appGreyishBrown())
                <> set(\MenuItemView.text, title.uppercased())

        case .regular(let title, let addSeparator):
            return MenuItemView(withSeparator: addSeparator)
                |> Style.View.whiteBackground()
                <> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .light))
                <> set(\MenuItemView.textColor, UIColor.appGreyishBrown())
                <> set(\MenuItemView.text, title)
            
        case .main(let title):
            return MenuItemView(withSeparator: false)
                |> Style.View.orangeBackground()
                <> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .light))
                <> set(\MenuItemView.textColor, UIColor.white)
                <> set(\MenuItemView.text, title)
        }
    }
}
