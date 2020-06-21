//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuItemView: UIView {

    private static func fontAndTitle(_ title: MenuItem.Title) -> (UIFont, String) {
        switch title {
        case .heavy(let string): return (.SFUIText(size: 15, type: .medium), string.uppercased())
        case .regular(let string): return (.SFUIText(size: 15, type: .light), string)
        }
    }

    static func header(text: String) -> MenuItemView {
        applyAndReturn(
            MenuItemView(withIcon: nil, addSeparator: false),
            set(\MenuItemView.label.font, UIFont.SFUIText(size: 15, type: .medium))
                <> set(\MenuItemView.label.textColor, UIColor.appGreyishBrown())
                <> set(\MenuItemView.label.text, text.uppercased()))
    }

    static func secondary(title: MenuItem.Title, icon: UIImage?, addSeparator: Bool) -> MenuItemView {
        let (font, text) = fontAndTitle(title)
        return applyAndReturn(
            MenuItemView(withIcon: icon, addSeparator: addSeparator),
            Style.View.whiteBackground()
                <> set(\MenuItemView.label.font, font)
                <> set(\MenuItemView.label.textColor, UIColor.appGreyishBrown())
                <> set(\MenuItemView.label.text, text))
    }

    static func main(text: String) -> MenuItemView {
        applyAndReturn(
            MenuItemView(withIcon: nil, addSeparator: false),
            Style.View.orangeBackground()
                <> set(\MenuItemView.label.font, UIFont.SFUIText(size: 15, type: .light))
                <> set(\MenuItemView.label.textColor, UIColor.white)
                <> set(\MenuItemView.label.text, text))
    }

    private enum Constants {
        static let height: CGFloat = 45
        static let separatorHeight: CGFloat = 1
        static let padding: CGFloat = 14
    }

    private let stackView = UIStackView()
    private let label = UILabel()
    private let imageView = UIImageView()

    convenience init(withIcon icon: UIImage?, addSeparator: Bool) {
        self.init(frame: .zero)

        self |> constraintHeight(Constants.height)

        stackView
            |> addInSuperview(self)
            <> pinEdgesToSuperview(.horizontal(Constants.padding))
            <> centerYInSuperview
            <> set(\UIStackView.spacing, Constants.padding)

        if let icon = icon {
            imageView
                |> addInStackView(stackView)
                <> constraintSize(width: 32, height: 32)
                <> set(\UIImageView.image, icon)
        }

        label
            |> addInStackView(stackView)

        if addSeparator {
            createView(withHeight: Constants.separatorHeight)
                |> addInSuperview(self)
                <> pinEdgesToSuperview([.leading(Constants.padding), .bottom(), .trailing()])
                <> set(\UIView.backgroundColor, UIColor.appGrey179)
        }
    }
}
