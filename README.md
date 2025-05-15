# ImmutableMultiset

[中文文档](./README_zh_CN.md)

# Usage

```moonbit
fn main {
    let set = @immunt_multiset.of([1, 2, 3, 3, 4])
    println(set.count(3))

    let set = @immunt_multiset.new().add(1, times=4).add(2).add(4)
    if set.contains(2) {
        println(set.count(2))
    }
}
```