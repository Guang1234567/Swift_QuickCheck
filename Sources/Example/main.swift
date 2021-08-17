import Foundation
import Swift_QuickCheck

/// 如何测试
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

public func appendArray(_ one: Int, _ two: [Int]) -> [Int] {
    two + [one]
}

check(message: "qsort should behave like sort") { (x: [Int]) in
    qsort(x) == x.sorted(by: <)
}

// overwrite Arbitrary rule
extension Int: Arbitrary {
    public static func arbitrary() -> Int {
        Int.random(in: -100...100)
    }
}

// overwrite Arbitrary rule
// @note:
//  ```
//  extension Array: Arbitrary where Element: Arbitrary { ... }
//  ```
// not working!
//
extension Array: Arbitrary where Element == Int {
    public static func arbitrary() -> [Element] {
        let randomLength = Int.random(in: 0...50)
        return tabulate(times: randomLength) { _ in
            Element.arbitrary()
        }
    }
}

check(message: "appendArray should behave like Array.append") { (x: Int, y: [Int]) in
    appendArray(x, y).elementsEqual(y + [x])
}

check(message: "appendArray should behave like Array.append",
        arbitraryA: Int.arbitrary,
        arbitraryB: Array.arbitrary
) { (x: Int, y: [Int]) in
    appendArray(x, y).elementsEqual([x] + y)
}
