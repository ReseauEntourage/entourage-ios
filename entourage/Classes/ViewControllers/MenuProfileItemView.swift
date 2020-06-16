//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

final class MenuProfileItemView: UIView {

    convenience init(name: String) {
        self.init(frame: .zero)

        self |> prepareForAutolayout

        let imageView = applyAndReturn(
            UIImageView(),
            addInSuperview(self)
                <> pinEdgeToSuperview(.top(20))
                <> centerXInSuperview
                <> constraintSize(width: 200, height: 200)
        )

        let nameLabel = applyAndReturn(
            UILabel(),
            addInSuperview(self)
                <> centerXInSuperview
                <> pinEdgesToSuperview(.horizontal(15, relation: .greaterThanOrEqual))
                <> pinTopToBottom(of: imageView)
                <> set(\UILabel.textColor, .red)
                <> set(\UILabel.text, name)
        )

        UIButton()
            |> addInSuperview(self)
            <> centerXInSuperview
            <> pinTopToBottom(of: nameLabel)
            <> pinEdgesToSuperview(.horizontal(15, relation: .greaterThanOrEqual) + [.bottom(-16)])
            <> flip(UIButton.setTitle)("Modifier mes informations", .normal)
    }
}
