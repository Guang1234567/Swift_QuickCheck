import Foundation

func tabulate<A>(times: Int, f: (Int) -> A) -> [A] {
    return Array(0..<times).map(f)
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
        return Int.random(in: Int.min...Int.max)
    }
}

extension Int: Smaller {
    public func smaller() -> Int? {
        return self == 0 ? nil : self / 2
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
    public func smaller() -> Character? { return nil }
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
        return self.isEmpty ? nil : String(self.dropFirst())
    }
}

extension Array: Arbitrary where Element: Arbitrary {
    public static func arbitrary() -> [Element] {
        let randomLength = Int.random(in: 0...50)
        return tabulate(times: randomLength) { _ in
            return Element.arbitrary()
        }
    }
}

extension Array: Smaller where Element: Arbitrary {
    public func smaller() -> [Element]? {
        if !self.isEmpty {
            return Array(self.dropFirst())
        }
        return nil
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

/// 用来测试
///
///     $ swift run --repl
///       1> import Swift_QuickCheck
///       2> check(message: "qsort should behave like sort") { (x: Array<Int>) in
///       3.     return qsort(x) == x.sorted(by: <)
///       4. }
///     "qsort should behave like sort" passed 100 tests.
///
public func qsort(_ array: [Int]) -> [Int] {
    if array.isEmpty {
        return []
    }
    var arr = array
    let pivot = arr.removeFirst()
    let lesser = arr.filter {
        $0 < pivot
    }
    let greater = arr.filter {
        $0 >= pivot
    }
    return qsort(lesser) + [pivot] + qsort(greater)
}
*/


