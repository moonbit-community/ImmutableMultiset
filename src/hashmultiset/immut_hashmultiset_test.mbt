///|
test "ImmuntableHashMultiset::new" {
  let set = new()
  let set2 = set.add(1)
  assert_eq(set.size(), 0)
  assert_eq(set2.size(), 1)
}

///|
test "ImmuntableHashMultiset::empty/size" {
  let set = ImmutableHashMultiset::new()
  assert_eq(set.size(), 0)
  assert_eq(set.is_empty(), true)
  assert_eq(set.contains(1), false)
}

///|
test "ImmuntableHashMultiset::add" {
  let mut set = ImmutableHashMultiset::new()
  set = set.add(1)
  set = set.add(2)
  assert_eq(set.size(), 2)
  assert_eq(set.count(1), 1)
  assert_eq(set.count(2), 1)
}

///|
test "ImmuntableHashMultiset::add/multiple" {
  let mut set = ImmutableHashMultiset::new()
  set = set.add(1, times=3)
  set = set.add(2, times=2)
  set = set.add(2, times=100)
  assert_eq(set.size(), 105)
  assert_eq(set.count(1), 3)
  assert_eq(set.count(2), 102)
}

///|
test "panic ImmuntableHashMultiset::add/zero" {
  let _ = ImmutableHashMultiset::new().add(1, times=0)

}

///|
test "panic ImmuntableHashMultiset::add/negative" {
  let _ = ImmutableHashMultiset::new().add(1, times=-1)

}

///|
test "ImmuntableHashMultiset::set" {
  let mut set = ImmutableHashMultiset::new()
  set = set.add(1, times=10)
  set = set.set(1, times=2)
  assert_eq(set.count(1), 2)
}

///|
test "panic ImmuntableHashMultiset::set/zero" {
  let _ = ImmutableHashMultiset::new().set(1, times=0)

}

///|
test "panic ImmuntableHashMultiset::set/negative" {
  let _ = ImmutableHashMultiset::new().set(1, times=-1)

}

///|
test "ImmuntableHashMultiset::contains" {
  let set = ImmutableHashMultiset::new()
  let set2 = set.add(1)
  assert_eq(set.contains(1), false)
  assert_eq(set2.contains(1), true)
}

///|
test "ImmuntableHashMultiset::contains/empty" {
  let set = ImmutableHashMultiset::new()
  assert_eq(set.contains(1), false)
}

///|
test "ImmuntableHashMultiset::count" {
  let set1 = of(["a", "b", "c", "b"])
  let set2 = set1.add("test")
  assert_eq(set1.count("a"), 1)
  assert_eq(set1.count("b"), 2)
  assert_eq(set2.count("c"), 1)
  assert_eq(set2.count("test"), 1)
}

///|
test "ImmuntableHashMultiset::remove" {
  let set = ImmutableHashMultiset::new()
  let _ = set.add("test")
  let _ = set.add("testitem")
  let _ = set.remove("testitem")
  assert_eq(set.contains("testitem"), false)
  assert_eq(set.size(), 0)
}

///|
test "ImmuntableHashMultiset::remove/multiple" {
  let mut set = ImmutableHashMultiset::new()
  set = set.add("test", times=10)
  set = set.remove("test", times=5)
  assert_eq(set.count("test"), 5)
}

///|
test "panic ImmuntableHashMultiset::remove/zero" {
  let _ = ImmutableHashMultiset::new().remove("test", times=0)

}

///|
test "ImmutableHashMultiset::remove_all" {
  let set = ImmutableHashMultiset::new().add(1, times=3).add(2)
  let set2 = set.remove_all(1)
  assert_eq(set2.count(1), 0)
  assert_eq(set2.count(2), 1)
}

///|
test "ImmutableHashMultiset::sum/basic" {
  let set1 = ImmutableHashMultiset::new().add(1).add(2).add(2)
  let set2 = ImmutableHashMultiset::new().add(2).add(3).add(3)
  let result = set1.sum(set2)
  inspect(result.count(1), content="1")
  inspect(result.count(2), content="3")
  inspect(result.count(3), content="2")
}

///|
test "ImmutableHashMultiset::sum/empty" {
  let empty = ImmutableHashMultiset::new()
  let set = ImmutableHashMultiset::new().add(1).add(2)
  let result1 = empty.sum(set)
  let result2 = set.sum(empty)
  inspect(result1.count(1), content="1")
  inspect(result1.count(2), content="1")
  inspect(result2.count(1), content="1")
  inspect(result2.count(2), content="1")
}

///|
test "ImmutableHashMultiset::sum/same_elements" {
  let set1 = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
  let set2 = ImmutableHashMultiset::new().add(1, times=2).add(2, times=4)
  let result = set1.sum(set2)
  inspect(result.count(1), content="5")
  inspect(result.count(2), content="6")
}

///|
test "ImmutableHashMultiset::union/basic" {
  let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
  let b = ImmutableHashMultiset::new().add(1, times=2).add(3, times=1)
  let union = a.union(b)
  assert_eq(union.count(1), 3)
  assert_eq(union.count(2), 2)
  assert_eq(union.count(3), 1)
}

///|
test "ImmutableHashMultiset::union/empty" {
  let empty = ImmutableHashMultiset::new()
  let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
  let union1 = empty.union(a)
  let union2 = a.union(empty)
  assert_eq(union1.count(1), 3)
  assert_eq(union1.count(2), 2)
  assert_eq(union2.count(1), 3)
  assert_eq(union2.count(2), 2)
  assert_eq(empty.size(), 0)
  assert_eq(a.size(), 5)
}

///|
test "ImmutableHashMultiset::difference/basic" {
  let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
  let b = ImmutableHashMultiset::new().add(1, times=2).add(3, times=1)
  let diff = a.difference(b)
  inspect(diff.count(1), content="1")
  inspect(diff.count(2), content="2")
  inspect(diff.count(3), content="0")
}

///|
test "ImmutableHashMultiset::difference/empty" {
  let a = ImmutableHashMultiset::new()
  let b = ImmutableHashMultiset::new().add(1, times=2)
  let empty_diff = a - b
  inspect(empty_diff.size(), content="0")
  let c = ImmutableHashMultiset::new().add(1, times=2)
  let d = ImmutableHashMultiset::new()
  let full_diff = c - d
  inspect(full_diff.count(1), content="2")
}

///|
test "ImmutableHashMultiset::difference/same_counts" {
  let a = ImmutableHashMultiset::new().add(1, times=2).add(2, times=2)
  let b = ImmutableHashMultiset::new().add(1, times=2).add(2, times=2)
  let diff = a - b
  inspect(diff.size(), content="0")
  inspect(diff.count(1), content="0")
  inspect(diff.count(2), content="0")
}

///|
test "ImmutableHashMultiset::of" {
  let set = of([1, 2, 2, 3])
  assert_eq(set.count(1), 1)
  assert_eq(set.count(2), 2)
  assert_eq(set.count(3), 1)
}

///|
test "ImmutableHashMultiset::iter" {
  let set = of([1, 2, 2, 3])
  assert_eq(
    set.iter().to_array(),
    Array::from_fixed_array([(3, 1), (2, 2), (1, 1)]),
  )
}

///|
test "ImmutableHashMultiset::iter/empty" {
  let set : ImmutableHashMultiset[Int] = ImmutableHashMultiset::new()
  assert_eq(set.iter().to_array(), Array::from_fixed_array([]))
}

///|
test "ImmutableHashMultiset::elements" {
  let set = of([1, 2, 2, 3])
  assert_eq(set.elems().to_array(), Array::from_fixed_array([3, 2, 1]))
}

///|
test "ImmutableHashMultiset::intersection" {
  let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
  let b = ImmutableHashMultiset::new().add(1, times=2).add(3, times=1)
  let inter = a.intersection(b)
  assert_eq(inter.count(1), 2)
  assert_eq(inter.count(2), 0)
  assert_eq(inter.count(3), 0)
}

///|
test "ImmutableHashMultiset::intersection" {
  let a = ImmutableHashMultiset::new().add(1).add(2).add(3)
  let b = ImmutableHashMultiset::new().add(2).add(3, times=5555).add(4)
  let inter = a & b
  assert_eq(inter.count(1), 0)
  assert_eq(inter.count(2), 1)
  assert_eq(inter.count(3), 1)
}

///|
test "ImmutableHashMultiset::singleton" {
  let a = ImmutableHashMultiset::new()
  let b = a.add(1)
  let c = a.add(2)
  assert_not_eq(b, c)
}

///|
test "ImmutableHashMultiset::eq" {
  let a = ImmutableHashMultiset::new()
  let b = a.add(1).add(2)
  let c = a.add(1).add(2)
  assert_eq(b, c)
}

///|
test "ImmutableMultiset::map" {
  let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
  let mapped = set.map(fn(count) { count * 2 })
  assert_eq(mapped.count(1), 4)
  assert_eq(mapped.count(2), 2)
}

///|
test "ImmutableMultiset::mapi" {
  let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
  let mapped = set.mapi(fn(item, count) {
    if item == 1 {
      count + 1
    } else {
      count
    }
  })
  assert_eq(mapped.count(1), 3)
  assert_eq(mapped.count(2), 1)
}

///|
test "ImmutableMultiset::filter" {
  let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
  let filtered = set.filter(fn(count) { count > 1 })
  assert_eq(filtered.count(1), 2)
  assert_eq(filtered.count(2), 0)
}

///|
test "ImmutableMultiset::filteri" {
  let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
  let filtered = set.filteri(fn(item, count) { item == 1 && count > 1 })
  assert_eq(filtered.count(1), 2)
  assert_eq(filtered.count(2), 0)
}
