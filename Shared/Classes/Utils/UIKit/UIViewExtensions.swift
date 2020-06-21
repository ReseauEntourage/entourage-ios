//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

func createView(withHeight height: CGFloat) -> UIView {
    applyAndReturn(
        UIView(),
        constraintHeight(height)
    )
}

func addInSuperview<V: UIView>(_ superview: UIView) -> (V) -> Void {
    UIView.addSubview(superview)
}

func addInStackView<V: UIView>(_ stackView: UIStackView) -> (V) -> Void {
    UIStackView.addArrangedSubview(stackView)
}


