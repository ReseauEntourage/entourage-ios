//
// Copyright (c) 2020 Entourage. All rights reserved.
//

enum MenuItem {

    enum Title {
        case regular(String)
        case heavy(String)
    }

    case profile(_ name: String)
    case spacing(_ value: CGFloat)
    case header(_ text: String)
    case secondary(_ title: Title,
                   icon: UIImage? = nil,
                   addSeparator: Bool = false)
    case main(_ text: String)
}
