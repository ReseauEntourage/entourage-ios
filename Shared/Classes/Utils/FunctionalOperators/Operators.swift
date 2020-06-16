//
// Copyright (c) 2020 Entourage. All rights reserved.
//

// swiftlint:disable identifier_name opening_brace

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

func |><A, B>(a: A, f: (A) -> B) -> B {
    f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>><A, B, C>(f: @escaping (A) -> B,
                  g: @escaping (B) -> C) -> (A) -> C {
    { g(f($0)) }
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

func <><A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    {
        f($0)
        g($0)
    }
}
// swiftlint:enable identifier_name opening_brace
