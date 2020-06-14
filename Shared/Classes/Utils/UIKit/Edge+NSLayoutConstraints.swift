//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

extension NSLayoutAnchor {

    @objc func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>,
                          constant: CGFloat,
                          relation: Edge.Relation) -> NSLayoutConstraint {
        switch relation {
        case .equal: return constraint(equalTo: anchor, constant: constant)
        case .lessThanOrEqual: return constraint(lessThanOrEqualTo: anchor, constant: constant)
        case .greaterThanOrEqual: return constraint(greaterThanOrEqualTo: anchor, constant: constant)
        }
    }
}

func createConstraint<V: UIView>(from view: V, to otherView: UIView) -> (Edge) -> NSLayoutConstraint {
    { edge in // swiftlint:disable:this opening_brace
        switch edge.anchor {
        case .top:
            return view.topAnchor.constraint(equalTo: otherView.topAnchor, constant: edge.constant, relation: edge.relation)
        case .leading:
            return view.leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: edge.constant, relation: edge.relation)
        case .bottom:
            return view.bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: edge.constant, relation: edge.relation)
        case .trailing:
            return view.trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: edge.constant, relation: edge.relation)

        }
    }
}

func createConstraints<V: UIView>(to otherView: UIView, with edges: [Edge]) -> (V) -> [NSLayoutConstraint] {
    { edges |> map(createConstraint(from: $0, to: otherView)) } // swiftlint:disable:this opening_brace
}
