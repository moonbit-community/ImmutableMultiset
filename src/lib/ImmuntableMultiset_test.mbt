///|
test "multiset::new" {
  let mut set = ImmutableMultiset::new()
  set = set.add(1)
  assert_eq!(set.size(), 1)
}

///|
test "multiset::empty " {
  let mut set = ImmutableMultiset::new()
  set = set.add(1)
  assert_eq!(set.size(), 1)
  assert_eq!(set.contains(1), true)
  assert_eq!(set.contains(2), false)
}

test "multiset::add" {
  let mut set = ImmutableMultiset::new()
  set = set.add(1)
  set = set.add(2)
  assert_eq!(set.size(), 2)
}

///|
test "multiset::count" {
  let mut set = ImmutableMultiset::new()
  set = set.add("test")
  set = set.add("testitem")
  set = set.add("testitem")
  set = set.add("testitem")
  assert_eq!(set.count("testitem"), 3)
}

test "multiset::remove" {
  let mut set = ImmutableMultiset::new()
  set = set.add("test")
  set = set.add("testitem")
  set = set.add("testitem")
  set = set.add("testitem")
  set = set.remove("testitem")
  assert_eq!(set.contains("testitem"), false)
}