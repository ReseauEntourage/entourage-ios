//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

func prepareForAutolayout<V: UIView>(_ view: V) -> V {
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}

func activateConstraints<V: UIView>(_ createConstraints: @escaping (V) -> [NSLayoutConstraint]) -> (V) -> V {
    prepareForAutolayout
        <> { view in
        (createConstraints(view) |> NSLayoutConstraint.activate)
        return view
    }
}

func pinEdges<V: UIView>(_ edges: [Edge] = .all(), to otherView: UIView) -> (V) -> V {
    createConstraints(to: otherView, with: edges) |> activateConstraints
}

func pinEdgesToSuperview<V: UIView>(_ edges: [Edge] = .all()) -> (V) -> V {
    { view in
        guard let superview = view.superview else {
            return view
        }
        return view |> pinEdges(edges, to: superview)
    }
}

func centerY<V: UIView>(to otherView: UIView) -> (V) -> V {
    activateConstraints() { [$0.centerYAnchor.constraint(equalTo: otherView.centerYAnchor)] }
}

func centerYInSuperview<V: UIView>(_ view: V) -> V {
    guard let superview = view.superview else {
        return view
    }
    return view |> centerY(to: superview)
}

func constraintHeight<V: UIView>(_ constant: CGFloat) -> (V) -> V {
    activateConstraints() { [$0.heightAnchor.constraint(equalToConstant: constant)] }
}

func constraintWidth<V: UIView>(toWidthOf otherView: UIView) -> (V) -> V {
    activateConstraints() { [$0.widthAnchor.constraint(equalTo: otherView.widthAnchor)] }
}
