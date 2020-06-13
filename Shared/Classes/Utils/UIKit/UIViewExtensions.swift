//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

func createView(withHeight height: CGFloat) -> UIView {
    UIView() |> constraintHeight(height)
}

func addInSuperview<V: UIView>(_ superview: UIView) -> (V) -> V {
    { view in
        superview.addSubview(view)
        return view
    }
}
