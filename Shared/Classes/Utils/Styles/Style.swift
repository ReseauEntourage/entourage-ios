//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

enum Style {

    enum View {

        static func greyBackground<V: UIView>() -> (V) -> Void {
            set(\V.backgroundColor, UIColor.appPaleGrey())
        }

        static func whiteBackground<V: UIView>() -> (V) -> Void {
            set(\V.backgroundColor, UIColor.white)
        }

        static func orangeBackground<V: UIView>() -> (V) -> Void {
            set(\V.backgroundColor, UIColor.appOrange())
        }
    }
}
