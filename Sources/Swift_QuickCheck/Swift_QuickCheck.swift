import Foundation

func tabulate<A>(times: Int, f: (Int) -> A) -> [A] {
    Array(0..<times).map(f)
}

func iterateWhile<A>(condition: (A) -> Bool, initialValue: A,
                     next: (A) -> A?) -> A {
    if let x = next(initialValue) {
        if condition(x) {
            return iterateWhile(condition: condition, initialValue: x, next: next)
        }
    }
    return initialValue
}


extension Character {
    func toInt() -> Int {
        var intFromCharacter: Int = 0
        for scalar in String(self).unicodeScalars {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
}

public protocol Smaller {
    func smaller() -> Self?
}

public protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    public static func arbitrary() -> Int {
        Int.random(in: Int.min...Int.max)
    }
}

extension Int: Smaller {
    public func smaller() -> Int? {
        self == 0 ? nil : self / 2
    }
}

extension Character: Arbitrary {
    public static func arbitrary() -> Character {
        let start: Int = ("A" as Character).toInt()
        let end: Int = ("Z" as Character).toInt()
        return Character(UnicodeScalar(Int.random(in: start...end)) ?? "A")
    }
}

extension Character: Smaller {
    public func smaller() -> Character? {
        nil
    }
}

extension String: Arbitrary {
    public static func arbitrary() -> String {
        let randomLength = Int.random(in: 0...40)
        let randomCharacters = tabulate(times: randomLength) { _ in
            Character.arbitrary()
        }

        return randomCharacters.reduce("") {
            $0 + String($1)
        }
    }
}

extension String: Smaller {
    public func smaller() -> String? {
        self.isEmpty ? nil : String(self.dropFirst())
    }
}

extension Array: Arbitrary where Element: Arbitrary {
    public static func arbitrary() -> [Element] {
        let randomLength = Int.random(in: 0...50)
        return tabulate(times: randomLength) { _ in
            Element.arbitrary()
        }
    }
}

extension Array: Smaller where Element: Arbitrary {
    public func smaller() -> [Element]? {
        self.isEmpty ? nil : Array(self.dropFirst())
    }
}

public func check<A: Arbitrary & Smaller>(message: String, size: Int = 100, prop: (A) -> Bool) -> () {
    for _ in 0..<size {
        let value = A.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile(condition: { !prop($0) }, initialValue: value) {
                $0.smaller()
            }
            print("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(size) tests.")
}

public func check<A: Arbitrary & Smaller, B: Arbitrary & Smaller>(message: String, size: Int = 100, prop: (A, B) -> Bool) -> () {
    for _ in 0..<size {
        let value0 = A.arbitrary()
        let value1 = B.arbitrary()
        if !prop(value0, value1) {
            let smallerValue0 = iterateWhile(condition: { !prop($0, value1) }, initialValue: value0) {
                $0.smaller()
            }

            let smallerValue1 = iterateWhile(condition: { !prop(smallerValue0, $0) }, initialValue: value1) {
                $0.smaller()
            }

            print("\"\(message)\" doesn't hold: (\(smallerValue0), \(smallerValue1))")
            return
        }
    }
    print("\"\(message)\" passed \(size) tests.")
}

public func check<A: Arbitrary & Smaller, B: Arbitrary & Smaller, C: Arbitrary & Smaller>(message: String, size: Int = 100, prop: (A, B, C) -> Bool) -> () {
    for _ in 0..<size {
        let value0 = A.arbitrary()
        let value1 = B.arbitrary()
        let value2 = C.arbitrary()
        if !prop(value0, value1, value2) {
            let smallerValue0 = iterateWhile(condition: { !prop($0, value1, value2) }, initialValue: value0) {
                $0.smaller()
            }

            let smallerValue1 = iterateWhile(condition: { !prop(smallerValue0, $0, value2) }, initialValue: value1) {
                $0.smaller()
            }

            let smallerValue2 = iterateWhile(condition: { !prop(smallerValue0, smallerValue1, $0) }, initialValue: value2) {
                $0.smaller()
            }

            print("\"\(message)\" doesn't hold: (\(smallerValue0), \(smallerValue1), \(smallerValue2))")
            return
        }
    }
    print("\"\(message)\" passed \(size) tests.")
}

public func check<A: Arbitrary & Smaller, B: Arbitrary & Smaller, C: Arbitrary & Smaller, D: Arbitrary & Smaller>(message: String, size: Int = 100, prop: (A, B, C, D) -> Bool) -> () {
    for _ in 0..<size {
        let value0 = A.arbitrary()
        let value1 = B.arbitrary()
        let value2 = C.arbitrary()
        let value3 = D.arbitrary()
        if !prop(value0, value1, value2, value3) {
            let smallerValue0 = iterateWhile(condition: { !prop($0, value1, value2, value3) }, initialValue: value0) {
                $0.smaller()
            }

            let smallerValue1 = iterateWhile(condition: { !prop(smallerValue0, $0, value2, value3) }, initialValue: value1) {
                $0.smaller()
            }

            let smallerValue2 = iterateWhile(condition: { !prop(smallerValue0, smallerValue1, $0, value3) }, initialValue: value2) {
                $0.smaller()
            }

            let smallerValue3 = iterateWhile(condition: { !prop(smallerValue0, smallerValue1, smallerValue2, $0) }, initialValue: value3) {
                $0.smaller()
            }

            print("\"\(message)\" doesn't hold: (\(smallerValue0), \(smallerValue1), \(smallerValue2), \(smallerValue3))")
            return
        }
    }
    print("\"\(message)\" passed \(size) tests.")
}

/*
/// 不要像下面这样子做, 因为做法已经过时.
/// https://blog.csdn.net/balternotz/article/details/62897481
public func check<A: Arbitrary>(message: String, size: Int = 100, prop: ([A]) -> Bool) -> () {
    for _ in 0..<size {
        let value = Array<A>.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile(condition: { !prop($0) }, initialValue: value) {
                $0.smaller()
            }
            print("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\"\(message)\" passed \(size) tests.")
}
*/

