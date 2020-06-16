//
// Copyright (c) 2020 Entourage. All rights reserved.
//

// swiftlint:disable identifier_name opening_brace

func get<Root: AnyObject, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    { $0[keyPath: kp] }
}

func set<Root: AnyObject, Value>(_ kp: ReferenceWritableKeyPath<Root, Value>,
                                 _ f: @escaping (Value) -> Value) -> (Root) -> Void {
    { $0[keyPath: kp] = f($0[keyPath: kp]) }
}

func set<Root: AnyObject, Value>(_ kp: ReferenceWritableKeyPath<Root, Value>, _ value: Value) -> (Root) -> Void {
    set(kp, { _ in value })
}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    { $0.map(f) }
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    { b in { a in f(a)(b) } }
}

func flip<A, B, C, D>(_ f: @escaping (A) -> (B, C) -> D) -> (B, C) -> (A) -> D {
    { b, c in
        { a in
            f(a)(b, c)
        }
    }
}

func applyAndReturn<A>(_ a: A, _ f: (A) -> Void) -> A {
    f(a)
    return a
}

// swiftlint:enable identifier_name opening_brace
