//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuItemView: UIView {

    var font: UIFont {
        get { label.font }
        set { label.font = newValue }
    }

    var textColor: UIColor {
        get { label.textColor }
        set { label.textColor = newValue }
    }

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }

    private let label = UILabel()

    private enum Constants {
        static let height: CGFloat = 45
        static let separatorHeight: CGFloat = 1
        static let padding: CGFloat = 14
    }

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
