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
    { superview.addSubview($0) } // swiftlint:disable:this opening_brace
}
