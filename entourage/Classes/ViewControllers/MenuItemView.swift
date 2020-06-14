//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuItemView: UIView {

    static func header(title: String) -> MenuItemView {
        MenuItemView(withSeparator: false)
            |> set(\MenuItemView.label.font, UIFont.SFUIText(size: 15, type: .medium))
            <> set(\MenuItemView.label.textColor, UIColor.appGreyishBrown())
            <> set(\MenuItemView.label.text, title.uppercased())
    }

    static func secondary(title: String, addSeparator: Bool) -> MenuItemView {
        MenuItemView(withSeparator: addSeparator)
            |> Style.View.whiteBackground()
            <> set(\MenuItemView.label.font, UIFont.SFUIText(size: 15, type: .light))
            <> set(\MenuItemView.label.textColor, UIColor.appGreyishBrown())
            <> set(\MenuItemView.label.text, title)
    }

    static func main(title: String) -> MenuItemView {
        MenuItemView(withSeparator: false)
            |> Style.View.orangeBackground()
            <> set(\MenuItemView.label.font, UIFont.SFUIText(size: 15, type: .light))
            <> set(\MenuItemView.label.textColor, UIColor.white)
            <> set(\MenuItemView.label.text, title)
    }

    private enum Constants {
        static let height: CGFloat = 45
        static let separatorHeight: CGFloat = 1
        static let padding: CGFloat = 14
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
