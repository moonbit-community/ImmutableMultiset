///| Immutable hash multiset (bag) implementation supporting efficient structural sharing. 
/// 
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::new" {
///   let set = ImmutableHashMultiset::new()
///   let set2 = set.add(1)
///   assert_eq!(set.size(), 0)
///   assert_eq!(set2.size(), 1) 
/// }
/// ```
pub struct ImmutableHashMultiset[T] {
  map : @immut/hashmap.T[T, Int]
  size : Int
}

///| Returns true if the multiset contains the given item.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::contains" {
///   let set = ImmutableHashMultiset::new().add(1)
///   assert_eq!(set.contains(1), true)
///   assert_eq!(set.contains(2), false)
/// }
/// ```
pub fn contains[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  item : T
) -> Bool {
  self.map.contains(item)
}

///| Creates a new empty multiset.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::new" {
///   let set = ImmutableHashMultiset::new()
///   assert_eq!(set.size(), 0)
/// }
/// ```
pub fn ImmutableHashMultiset::new[T]() -> ImmutableHashMultiset[T] {
  { map: @immut/hashmap.new(), size: 0 }
}

///| Creates a new empty multiset.
pub fn new[T]() -> ImmutableHashMultiset[T] {
  ImmutableHashMultiset::new()
}

///| Returns the number of occurrences of an item in the multiset.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::count" {
///   let set = ImmutableHashMultiset::new().add("a").add("a")
///   assert_eq!(set.count("a"), 2)
///   assert_eq!(set.count("b"), 0)
/// }
/// ```
pub fn count[T : Eq + Hash](self : ImmutableHashMultiset[T], item : T) -> Int {
  self.map.get(item).or_else(fn() { 0 })
}

///| Adds an item to the multiset. If it already exists, increments the count.
///
/// # Panics
/// Panics if `times < 1`.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::add" {
///   let set = ImmutableHashMultiset::new().add(1, times=3).add(2)
///   assert_eq!(set.count(1), 3)
/// }
/// ```
pub fn add[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableHashMultiset[T] {
  if times < 1 {
    abort("times must be 1 or greater")
  }
  let element_count = self.count(item)
  { map: self.map.add(item, element_count + times), size: self.size + times }
}

///| Sets the count of an item in the multiset, replacing any previous count.
///
/// # Panics
/// Panics if `times < 1`.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::set" {
///   let set = ImmutableHashMultiset::new().add(1, times=10).set(1, times=2)
///   assert_eq!(set.count(1), 2)
/// }
/// ```
pub fn set[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableHashMultiset[T] {
  if times < 1 {
    abort("times must be 1 or greater")
  }
  let count = self.count(item)
  let new_size = if count == 0 {
    self.size + times
  } else {
    self.size - count + times
  }
  { map: self.map.add(item, times), size: new_size }
}

///| Removes an item from the multiset. If `times == -1`, removes all occurrences.
///
/// # Panics
/// Panics if `times == 0` or `times < -1`.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::remove" {
///   let set = ImmutableHashMultiset::new().add("test", times=10).remove("test", times=5)
///   assert_eq!(set.count("test"), 5)
/// }
/// ```
pub fn remove[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableHashMultiset[T] {
  if times < -1 || times == 0 {
    abort("times must be -1 or greater zero")
  }
  let element_count = self.count(item)
  if times == -1 {
    { map: self.map.remove(item), size: self.size - element_count }
  } else if element_count > times {
    { map: self.map.add(item, element_count - times), size: self.size - times }
  } else {
    { map: self.map.remove(item), size: self.size - element_count }
  }
}

///| Removes all occurrences of an item from the multiset.
/// 
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::remove_all" {
///  let set = ImmutableHashMultiset::new().add(1, times=3).add(2)
///  let set2 = set.remove_all(1)
///  assert_eq!(set2.count(1), 0)
///  assert_eq!(set2.count(2), 1)
/// }
/// ```
pub fn remove_all[T : Hash + Eq](
  self : ImmutableHashMultiset[T],
  item : T
) -> ImmutableHashMultiset[T] {
  if self.contains(item) {
    { map: self.map.remove(item), size: self.size - self.count(item) }
  } else {
    self
  }
}

///| Returns the total number of elements in the multiset (including duplicates).
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::size" {
///   let set = ImmutableHashMultiset::new().add(1, times=3).add(2)
///   assert_eq!(set.size(), 4)
/// }
/// ```
pub fn size[T](self : ImmutableHashMultiset[T]) -> Int {
  self.size
}

///| Returns true if the multiset is empty.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::is_empty" {
///   let set = ImmutableHashMultiset::new()
///   assert_eq!(set.is_empty(), true)
/// }
/// ```
pub fn is_empty[T](self : ImmutableHashMultiset[T]) -> Bool {
  self.size == 0
}

// Two multisets operations

///| Returns the intersection of two multisets. For each item, the minimum count is taken.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::intersection" {
///   let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
///   let b = ImmutableHashMultiset::new().add(1, times=2).add(3, times=1)
///   let inter = a.intersection(b)
///   assert_eq!(inter.count(1), 2)
///   assert_eq!(inter.count(2), 0)
///   assert_eq!(inter.count(3), 0)
/// }
/// ```
pub fn intersection[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  other : ImmutableHashMultiset[T]
) -> ImmutableHashMultiset[T] {
  let new_set = if self.size() > other.size() {
    let mut new_set = other
    for item, count in other.iter2() {
      let self_count = self.count(item)
      if self_count > 0 {
        let min_count = @math.minimum(count, self_count)
        new_set = new_set.set(item, times=min_count)
      } else {
        new_set = new_set.remove(item)
      }
    }
    new_set
  } else {
    let mut new_set = self
    for item, count in self.iter2() {
      let other_count = other.count(item)
      if other_count > 0 {
        let min_count = @math.minimum(count, other_count)
        new_set = new_set.set(item, times=min_count)
      } else {
        new_set = new_set.remove(item)
      }
    }
    new_set
  }
  new_set
}

///| Returns the difference of two multisets. For each item, the difference of counts is taken.
/// If the count in the first multiset is less than or equal to the second, the item is removed.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::difference" {
///   let a = ImmutableHashMultiset::new().add(1, times=3).add(2, times=2)
///   let b = ImmutableHashMultiset::new().add(1, times=2).add(3, times=1)
///   let diff = a.difference(b)
///   assert_eq!(diff.count(1), 1)
///   assert_eq!(diff.count(2), 2)
///   assert_eq!(diff.count(3), 0)
/// }
/// ```
pub fn difference[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  other : ImmutableHashMultiset[T]
) -> ImmutableHashMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    let other_count = other.count(item)
    if other_count > 0 {
      if count > other_count {
        new_set = new_set.remove(item, times=other_count)
      } else {
        new_set = new_set.remove_all(item)
      }
    }
  }
  new_set
}

///| Returns the union of two multisets.  For each item, the sum of counts is taken.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::sum" {
///   let set1 = ImmutableHashMultiset::new().add(1).add(2).add(2)
///   let set2 = ImmutableHashMultiset::new().add(2).add(3).add(3)
///   let result = set1.sum(set2)
///   assert_eq!(result.count(1), 1)
///   assert_eq!(result.count(2), 3)
///   assert_eq!(result.count(3), 2)
/// }
/// ```
pub fn sum[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  other : ImmutableHashMultiset[T]
) -> ImmutableHashMultiset[T] {
  let new_set = if self.size() > other.size() {
    let mut new_set = self
    for item, count in other.iter2() {
      new_set = self.add(item, times=count)
    }
    new_set
  } else {
    let mut new_set = other
    for item, count in self.iter2() {
      new_set = new_set.add(item, times=count)
    }
    new_set
  }
  new_set
}

///| Returns the union of two multisets. For each item, the maximum count is taken.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::union" {
///   let set1 = ImmutableHashMultiset::new().add(1).add(2).add(2)
///   let set2 = ImmutableHashMultiset::new().add(2).add(3, times=4).add(3)
///   let result = set1.union(set2)
///   assert_eq!(result.count(1), 1)
///   assert_eq!(result.count(2), 3)
///   assert_eq!(result.count(3), 5)
/// }
/// ```
pub fn union[T : Eq + Hash](
  self : ImmutableHashMultiset[T],
  other : ImmutableHashMultiset[T]
) -> ImmutableHashMultiset[T] {
  let new_set = if self.size() > other.size() {
    let mut new_set = self
    for item, count in other.iter2() {
      new_set = new_set.set(item, times=@math.maximum(count, self.count(item)))
    }
    new_set
  } else {
    let mut new_set = other
    for item, count in self.iter2() {
      new_set = new_set.set(item, times=@math.maximum(count, other.count(item)))
    }
    new_set
  }
  new_set
}

///| Returns all distinct elements in the multiset (ignoring counts).
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::elems" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let elems = set.elems().collect()
///   assert!(elems.contains(1))
///   assert!(elems.contains(2))
/// }
/// ```
pub fn elems[T : Eq + Hash](self : ImmutableHashMultiset[T]) -> Iter[T] {
  self.map.keys()
}

///| Returns a new multiset where the count of each element is updated by applying `f` to its current count.
/// Elements are passed to `f` in increasing order according to their type's ordering.
/// 
/// # Panics
/// Panics if `f` returns a non-positive value for any element.
/// 
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::map" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let mapped = set.map(fn(count) { count * 2 })
///   assert_eq!(mapped.count(1), 4)
///   assert_eq!(mapped.count(2), 2)
/// }
/// ```
pub fn map[T : Hash + Eq](
  self : ImmutableHashMultiset[T],
  f : (Int) -> Int
) -> ImmutableHashMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    new_set = new_set.set(item, times=f(count))
  }
  new_set
}

///| Returns a new multiset where the count of each element is updated by applying `f` to the element and its current count.
/// Elements are passed to `f` in increasing order according to their type's ordering.
/// 
/// # Panics
/// Panics if `f` returns a non-positive value for any element.
/// 
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::mapi" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let mapped = set.mapi(fn(item, count) { if item == 1 { count + 1 } else { count } })
///   assert_eq!(mapped.count(1), 3)
///   assert_eq!(mapped.count(2), 1)
/// }
/// ```
pub fn mapi[T : Hash + Eq](
  self : ImmutableHashMultiset[T],
  f : (T, Int) -> Int
) -> ImmutableHashMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    new_set = new_set.set(item, times=f(item, count))
  }
  new_set
}

///| Returns a new multiset containing only elements whose count satisfies the predicate `f`.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::filter" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let filtered = set.filter(fn(count) { count > 1 })
///   assert_eq!(filtered.count(1), 2)
///   assert_eq!(filtered.count(2), 0)
/// }
/// ```
pub fn filter[T : Hash + Eq](
  self : ImmutableHashMultiset[T],
  f : (Int) -> Bool
) -> ImmutableHashMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    if f(count) {
      new_set = new_set.set(item, times=count)
    } else {
      new_set = new_set.remove(item)
    }
  }
  new_set
}

///| Returns a new multiset containing only elements for which the predicate `f(item, count)` returns true.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::filteri" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let filtered = set.filteri(fn(item, count) { item == 1 && count > 1 })
///   assert_eq!(filtered.count(1), 2)
///   assert_eq!(filtered.count(2), 0)
/// }
/// ```
pub fn filteri[T : Hash + Eq](
  self : ImmutableHashMultiset[T],
  f : (T, Int) -> Bool
) -> ImmutableHashMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    if f(item, count) {
      new_set = new_set.set(item, times=count)
    } else {
      new_set = new_set.remove(item)
    }
  }
  new_set
}

///| Returns an iterator over (element, count) pairs in the multiset.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::iter" {
///   let set = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   for item, count in set.iter() {
///      assert!(item == 1 || item == 2)
///   }
/// }
/// ```
pub fn iter[T : Eq + Hash](self : ImmutableHashMultiset[T]) -> Iter[(T, Int)] {
  self.map.iter()
}

///|
pub fn iter2[T : Eq + Hash](self : ImmutableHashMultiset[T]) -> Iter2[T, Int] {
  self.map.iter2()
}

///|
pub fn op_get[T : Eq + Hash](self : ImmutableHashMultiset[T], item : T) -> Int {
  self.count(item)
}

///|
pub impl[T : Eq + Hash] BitOr for ImmutableHashMultiset[T] with lor(
  self,
  other : ImmutableHashMultiset[T]
) {
  self.union(other)
}

///|
pub impl[T : Eq + Hash] BitAnd for ImmutableHashMultiset[T] with land(
  self,
  other : ImmutableHashMultiset[T]
) {
  self.intersection(other)
}

///|
pub impl[T : Eq + Hash] Sub for ImmutableHashMultiset[T] with op_sub(
  self,
  other : ImmutableHashMultiset[T]
) {
  self.difference(other)
}

///|
pub impl[T : Eq + Hash] Add for ImmutableHashMultiset[T] with op_add(
  self,
  other : ImmutableHashMultiset[T]
) {
  self.sum(other)
}

///|
/// Compares two multisets for equality. O(n) time complexity.
/// 
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::eq" {
///   let set1 = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let set2 = ImmutableHashMultiset::new().add(1, times=2).add(2)
///   let set3 = ImmutableHashMultiset::new().add(1, times=2).add(3)
///   assert_eq!(set1 == set2, true)
///   assert_eq!(set1 == set3, false)
/// }
pub impl[T : Eq + Hash] Eq for ImmutableHashMultiset[T] with op_equal(
  self : ImmutableHashMultiset[T],
  other : ImmutableHashMultiset[T]
) {
  if self.size != other.size {
    return false
  }
  for item, count in self.map.iter2() {
    let other_count = other.count(item)
    if count != other_count {
      return false
    }
  }
  true
}

///|
pub impl[T : Eq + Hash + Show] Show for ImmutableHashMultiset[T] with output(
  self : ImmutableHashMultiset[T],
  logger : &Logger
) {
  logger.write_iter(
    self.iter(),
    prefix="@ImmutableHashMultiset.of([",
    suffix="])",
  )
}

///| Converts a FixedArray to an ImmutableHashMultiset.
///
/// # Examples
/// ```moonbit
/// test "ImmutableHashMultiset::of" {
///   let set = ImmutableHashMultiset::of([1, 2, 2])
///   assert_eq!(set.count(1), 1)
///   assert_eq!(set.count(2), 2)
/// }
/// ```
pub fn of[T : Eq + Hash](arr : FixedArray[T]) -> ImmutableHashMultiset[T] {
  let mut set = ImmutableHashMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///| Converts an Array to an ImmutableHashMultiset.
pub fn from_array[T : Eq + Hash](arr : Array[T]) -> ImmutableHashMultiset[T] {
  let mut set = ImmutableHashMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///| Converts an iterator to an ImmutableHashMultiset.
pub fn from_iter[T : Eq + Hash](iter : Iter[T]) -> ImmutableHashMultiset[T] {
  let mut set = ImmutableHashMultiset::new()
  for item in iter {
    set = set.add(item)
  }
  set
}

///| Converts an iterator of (element, count) pairs to an ImmutableHashMultiset.
pub fn from_iter2[T : Eq + Hash](
  iter : Iter2[T, Int]
) -> ImmutableHashMultiset[T] {
  let mut set = ImmutableHashMultiset::new()
  for item, times in iter {
    set = set.add(item, times~)
  }
  set
}
