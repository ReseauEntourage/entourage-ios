//
// Copyright (c) 2020 Entourage. All rights reserved.
//

func get<Root: AnyObject, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    { $0[keyPath: kp] }
}

func set<Root: AnyObject, Value>(_ kp: ReferenceWritableKeyPath<Root, Value>,
                                 _ f: @escaping (Value) -> Value) -> (Root) -> Root {
    { root in
        root[keyPath: kp] = f(root[keyPath: kp])
        return root
    }
}

func set<Root: AnyObject, Value>(_ kp: ReferenceWritableKeyPath<Root, Value>, _ value: Value) -> (Root) -> Root {
    set(kp, { _ in value })
}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    { $0.map(f) }
}
