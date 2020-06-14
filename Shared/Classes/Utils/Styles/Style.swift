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
