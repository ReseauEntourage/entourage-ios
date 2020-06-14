//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuItemView: UIView {

    static func header(title: String) -> MenuItemView {
        MenuItemView(withSeparator: false)
            |> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .medium))
            <> set(\MenuItemView.textColor, UIColor.appGreyishBrown())
            <> set(\MenuItemView.text, title.uppercased())
    }

    static func secondary(title: String, addSeparator: Bool) -> MenuItemView {
        MenuItemView(withSeparator: addSeparator)
            |> Style.View.whiteBackground()
            <> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .light))
            <> set(\MenuItemView.textColor, UIColor.appGreyishBrown())
            <> set(\MenuItemView.text, title)
    }

    static func main(title: String) -> MenuItemView {
        MenuItemView(withSeparator: false)
            |> Style.View.orangeBackground()
            <> set(\MenuItemView.font, UIFont.SFUIText(size: 15, type: .light))
            <> set(\MenuItemView.textColor, UIColor.white)
            <> set(\MenuItemView.text, title)
    }

    private enum Constants {
        static let height: CGFloat = 45
        static let separatorHeight: CGFloat = 1
        static let padding: CGFloat = 14
    }

    private var font: UIFont {
        get { label.font }
        set { label.font = newValue }
    }

    private var textColor: UIColor {
        get { label.textColor }
        set { label.textColor = newValue }
    }

    private var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let label = UILabel()

    convenience init(withSeparator: Bool) {
        self.init(frame: .zero)

        self |> constraintHeight(Constants.height)

        label
            |> addInSuperview(self)
            <> pinEdgesToSuperview(.horizontal(Constants.padding))
            <> centerYInSuperview

        if withSeparator {
            createView(withHeight: Constants.separatorHeight)
                |> addInSuperview(self)
                <> pinEdgesToSuperview([.leading(Constants.padding), .bottom(), .trailing()])
                <> set(\UIView.backgroundColor, UIColor.appGrey179)
        }
    }
}
