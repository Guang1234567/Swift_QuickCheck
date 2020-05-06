# Swift_QuickCheck

Like `QuickCheck` in `Haskell`, but reimplemented by `Swift`

# Usage

- Some function to tested

```swift
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
```

- Using `QuickCheck` to test `qsort` function

```bash
$ swift run --repl

1> import Swift_QuickCheck
2> check(message: "qsort should behave like sort") { (x: Array<Int>) in
3.     return qsort(x) == x.sorted(by: <)
4. }
"qsort should behave like sort" passed 100 tests.
```

That's all !