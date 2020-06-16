//
// Copyright (c) 2020 Entourage. All rights reserved.
//

import UIKit

func prepareForAutolayout<V: UIView>(_ view: V) {
    view.translatesAutoresizingMaskIntoConstraints = false
}

func activateConstraints<V: UIView>(_ createConstraints: @escaping (V) -> [NSLayoutConstraint]) -> (V) -> Void {
    prepareForAutolayout
        <> { (createConstraints($0) |> NSLayoutConstraint.activate)
    }
}

func pinEdge<V: UIView>(_ edge: Edge, to otherView: UIView) -> (V) -> Void {
    pinEdges([edge], to: otherView)
}

func pinEdgeToSuperview<V: UIView>(_ edge: Edge) -> (V) -> Void {
    pinEdgesToSuperview([edge])
}

func pinEdges<V: UIView>(_ edges: [Edge] = .all(), to otherView: UIView) -> (V) -> Void {
    createConstraints(to: otherView, with: edges) |> activateConstraints
}

func pinEdgesToSuperview<V: UIView>(_ edges: [Edge] = .all()) -> (V) -> Void {
    { view in // swiftlint:disable:this opening_brace
        guard let superview = view.superview else {
            return
        }
        return view |> pinEdges(edges, to: superview)
    }
}

func centerX<V: UIView>(to otherView: UIView) -> (V) -> Void {
    activateConstraints { [$0.centerXAnchor.constraint(equalTo: otherView.centerXAnchor)] }
}

func centerY<V: UIView>(to otherView: UIView) -> (V) -> Void {
    activateConstraints { [$0.centerYAnchor.constraint(equalTo: otherView.centerYAnchor)] }
}

func centerXInSuperview<V: UIView>(_ view: V) {
    guard let superview = view.superview else {
        return
    }
    return view |> centerX(to: superview)
}

func centerYInSuperview<V: UIView>(_ view: V) {
    guard let superview = view.superview else {
        return
    }
    return view |> centerY(to: superview)
}

func constraintHeight<V: UIView>(_ constant: CGFloat) -> (V) -> Void {
    activateConstraints { [$0.heightAnchor.constraint(equalToConstant: constant)] }
}

func constraintWidth<V: UIView>(_ constant: CGFloat) -> (V) -> Void {
    activateConstraints { [$0.widthAnchor.constraint(equalToConstant: constant)] }
}

func constraintSize<V: UIView>(width: CGFloat, height: CGFloat) -> (V) -> Void {
    constraintWidth(width) <> constraintHeight(height)
}

func constraintWidth<V: UIView>(toWidthOf otherView: UIView) -> (V) -> Void {
    activateConstraints { [$0.widthAnchor.constraint(equalTo: otherView.widthAnchor)] }
}

func pinTopToBottom<V: UIView>(of otherView: UIView) -> (V) -> Void {
    activateConstraints { [$0.topAnchor.constraint(equalTo: otherView.bottomAnchor)] }
}
