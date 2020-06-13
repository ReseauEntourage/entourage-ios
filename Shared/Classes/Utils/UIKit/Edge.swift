//
// Copyright (c) 2020 Entourage. All rights reserved.
//

struct Edge {

    enum Anchor {
        case top, leading, bottom, trailing
    }

    @objc enum Relation: Int {
        case equal, lessThanOrEqual, greaterThanOrEqual
    }

    static func top(_ constant: CGFloat = 0, relation: Relation = .equal) -> Edge {
        Edge(anchor: .top, constant: constant, relation: relation)
    }

    static func leading(_ constant: CGFloat = 0, relation: Relation = .equal) -> Edge {
        Edge(anchor: .leading, constant: constant, relation: relation)
    }

    static func bottom(_ constant: CGFloat = 0, relation: Relation = .equal) -> Edge {
        Edge(anchor: .bottom, constant: constant, relation: relation)
    }

    static func trailing(_ constant: CGFloat = 0, relation: Relation = .equal) -> Edge {
        Edge(anchor: .trailing, constant: constant, relation: relation)
    }

    let anchor: Anchor
    let constant: CGFloat
    let relation: Relation
}

extension Array where Element == Edge {

    static func all(_ constant: CGFloat = 0) -> [Edge] {
        [.top(constant), .leading(constant), .bottom(-constant), .trailing(-constant)]
    }

    static func horizontal(_ constant: CGFloat = 0) -> [Edge] {
        [.leading(constant), .trailing(-constant)]
    }
}
