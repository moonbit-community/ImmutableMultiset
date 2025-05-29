///| Immutable multiset (bag) implementation supporting efficient structural sharing.
/// 
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::new" {
///   let set = ImmutableMultiset::new()
///   let set2 = set.add(1)
///   assert_eq!(set.size(), 0)
///   assert_eq!(set2.size(), 1) 
/// }
/// ```
pub struct ImmutableMultiset[T] {
  map : @immut/sorted_map.T[T, Int]
  size : Int
}

///| Returns true if the multiset contains the given item.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::contains" {
///   let set = ImmutableMultiset::new().add(1)
///   assert_eq!(set.contains(1), true)
///   assert_eq!(set.contains(2), false)
/// }
/// ```
pub fn contains[T : Compare](self : ImmutableMultiset[T], item : T) -> Bool {
  self.map.contains(item)
}

///| Creates a new empty multiset.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::new" {
///   let set = ImmutableMultiset::new()
///   assert_eq!(set.size(), 0)
/// }
/// ```
pub fn ImmutableMultiset::new[T]() -> ImmutableMultiset[T] {
  { map: @immut/sorted_map.new(), size: 0 }
}

///| Creates a new empty multiset.
pub fn new[T]() -> ImmutableMultiset[T] {
  ImmutableMultiset::new()
}

///| Returns the number of occurrences of an item in the multiset.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::count" {
///   let set = ImmutableMultiset::new().add("a").add("a")
///   assert_eq!(set.count("a"), 2)
///   assert_eq!(set.count("b"), 0)
/// }
/// ```
pub fn count[T : Compare](self : ImmutableMultiset[T], item : T) -> Int {
  self.map.get(item).or_else(fn() { 0 })
}

///| Adds an item to the multiset. If it already exists, increments the count.
///
/// # Panics
/// Panics if `times < 1`.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::add" {
///   let set = ImmutableMultiset::new().add(1, times=3).add(2)
///   assert_eq!(set.count(1), 3)
/// }
/// ```
pub fn add[T : Compare](
  self : ImmutableMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::set" {
///   let set = ImmutableMultiset::new().add(1, times=10).set(1, times=2)
///   assert_eq!(set.count(1), 2)
/// }
/// ```
pub fn set[T : Compare](
  self : ImmutableMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableMultiset[T] {
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

///| Removes an item from the multiset.
///
/// # Panics
/// Panics if `times < 1`.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::remove" {
///   let set = ImmutableMultiset::new().add("test", times=10).remove("test", times=5)
///   assert_eq!(set.count("test"), 5)
/// }
/// ```
pub fn remove[T : Compare](
  self : ImmutableMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableMultiset[T] {
  if times < 1 {
    abort("times must be 1 or greater")
  }
  let element_count = self.count(item)
  if element_count > times {
    { map: self.map.add(item, element_count - times), size: self.size - times }
  } else {
    { map: self.map.remove(item), size: self.size - element_count }
  }
}

///| Removes all occurrences of an item from the multiset.
/// 
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::remove_all" {
///  let set = ImmutableMultiset::new().add(1, times=3).add(2)
///  let set2 = set.remove_all(1)
///  assert_eq!(set2.count(1), 0)
///  assert_eq!(set2.count(2), 1)
/// }
/// ```
pub fn remove_all[T : Compare](
  self : ImmutableMultiset[T],
  item : T
) -> ImmutableMultiset[T] {
  if self.contains(item) {
    { map: self.map.remove(item), size: self.size - self.count(item) }
  } else {
    self
  }
}

///| Returns the total number of elements in the multiset (including duplicates).
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::size" {
///   let set = ImmutableMultiset::new().add(1, times=3).add(2)
///   assert_eq!(set.size(), 4)
/// }
/// ```
pub fn size[T](self : ImmutableMultiset[T]) -> Int {
  self.size
}

///| Returns true if the multiset is empty.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::is_empty" {
///   let set = ImmutableMultiset::new()
///   assert_eq!(set.is_empty(), true)
/// }
/// ```
pub fn is_empty[T](self : ImmutableMultiset[T]) -> Bool {
  self.size == 0
}

// Two multisets operations

///| Returns the intersection of two multisets. For each item, the minimum count is taken.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::intersection" {
///   let a = ImmutableMultiset::new().add(1, times=3).add(2, times=2)
///   let b = ImmutableMultiset::new().add(1, times=2).add(3, times=1)
///   let inter = a.intersection(b)
///   assert_eq!(inter.count(1), 2)
///   assert_eq!(inter.count(2), 0)
///   assert_eq!(inter.count(3), 0)
/// }
/// ```
pub fn intersection[T : Compare](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::difference" {
///   let a = ImmutableMultiset::new().add(1, times=3).add(2, times=2)
///   let b = ImmutableMultiset::new().add(1, times=2).add(3, times=1)
///   let diff = a.difference(b)
///   assert_eq!(diff.count(1), 1)
///   assert_eq!(diff.count(2), 2)
///   assert_eq!(diff.count(3), 0)
/// }
/// ```
pub fn difference[T : Compare](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
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

///| Returns the union of two multisets. For each item, the sum of counts is taken.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::sum" {
///   let set1 = ImmutableMultiset::new().add(1).add(2).add(2)
///   let set2 = ImmutableMultiset::new().add(2).add(3).add(3)
///   let result = set1.sum(set2)
///   assert_eq!(result.count(1), 1)
///   assert_eq!(result.count(2), 3)
///   assert_eq!(result.count(3), 2)
/// }
/// ```
pub fn sum[T : Compare](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
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
pub fn union[T : Compare](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::elems" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   let elems = set.elems().collect()
///   assert!(elems.contains(1))
///   assert!(elems.contains(2))
/// }
/// ```
pub fn elems[T : Compare](self : ImmutableMultiset[T]) -> Iter[T] {
  self.map.keys().iter()
}

///| Returns a new multiset where the count of each element is updated by applying `f` to its current count.
/// Elements are passed to `f` in increasing order according to their type's ordering.
/// 
/// # Panics
/// Panics if `f` returns a non-positive value for any element.
/// 
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::map" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   let mapped = set.map(fn(count) { count * 2 })
///   assert_eq!(mapped.count(1), 4)
///   assert_eq!(mapped.count(2), 2)
/// }
/// ```
pub fn map[T : Compare](
  self : ImmutableMultiset[T],
  f : (Int) -> Int
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::mapi" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   let mapped = set.mapi(fn(item, count) { if item == 1 { count + 1 } else { count } })
///   assert_eq!(mapped.count(1), 3)
///   assert_eq!(mapped.count(2), 1)
/// }
/// ```
pub fn mapi[T : Compare](
  self : ImmutableMultiset[T],
  f : (T, Int) -> Int
) -> ImmutableMultiset[T] {
  let mut new_set = self
  for item, count in self.iter2() {
    new_set = new_set.set(item, times=f(item, count))
  }
  new_set
}

///| Returns a new multiset containing only elements whose count satisfies the predicate `f`.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::filter" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   let filtered = set.filter(fn(count) { count > 1 })
///   assert_eq!(filtered.count(1), 2)
///   assert_eq!(filtered.count(2), 0)
/// }
/// ```
pub fn filter[T : Compare](
  self : ImmutableMultiset[T],
  f : (Int) -> Bool
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::filteri" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   let filtered = set.filteri(fn(item, count) { item == 1 && count > 1 })
///   assert_eq!(filtered.count(1), 2)
///   assert_eq!(filtered.count(2), 0)
/// }
/// ```
pub fn filteri[T : Compare](
  self : ImmutableMultiset[T],
  f : (T, Int) -> Bool
) -> ImmutableMultiset[T] {
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
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::iter" {
///   let set = ImmutableMultiset::new().add(1, times=2).add(2)
///   for item, count in set.iter() {
///      assert!(item == 1 || item == 2)
///   }
/// }
/// ```
pub fn iter[T : Compare](self : ImmutableMultiset[T]) -> Iter[(T, Int)] {
  self.map.iter()
}

///|
pub fn iter2[T : Compare](self : ImmutableMultiset[T]) -> Iter2[T, Int] {
  self.map.iter2()
}

///|
pub fn op_get[T : Compare](self : ImmutableMultiset[T], item : T) -> Int {
  self.count(item)
}

///|
pub impl[T : Compare] BitOr for ImmutableMultiset[T] with lor(
  self,
  other : ImmutableMultiset[T]
) {
  self.union(other)
}

///|
pub impl[T : Compare] BitAnd for ImmutableMultiset[T] with land(
  self,
  other : ImmutableMultiset[T]
) {
  self.intersection(other)
}

///|
pub impl[T : Compare] Sub for ImmutableMultiset[T] with op_sub(
  self,
  other : ImmutableMultiset[T]
) {
  self.difference(other)
}

///|
pub impl[T : Compare] Add for ImmutableMultiset[T] with op_add(
  self,
  other : ImmutableMultiset[T]
) {
  self.sum(other)
}

///|
/// Compares two multisets for equality. O(n) time complexity.
/// 
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::eq" {
///   let set1 = ImmutableMultiset::new().add(1, times=2).add(2)
///   let set2 = ImmutableMultiset::new().add(1, times=2).add(2)
///   let set3 = ImmutableMultiset::new().add(1, times=2).add(3)
///   assert_eq!(set1 == set2, true)
///   assert_eq!(set1 == set3, false)
/// }
pub impl[T : Compare] Eq for ImmutableMultiset[T] with op_equal(
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
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
pub impl[T : Compare + Show] Show for ImmutableMultiset[T] with output(
  self : ImmutableMultiset[T],
  logger : &Logger
) {
  logger.write_iter(self.iter(), prefix="@ImmutableMultiset.of([", suffix="])")
}

///| Converts a FixedArray to an ImmutableMultiset.
///
/// # Example:
/// 
/// ```moonbit
/// test "ImmutableMultiset::of" {
///   let set = ImmutableMultiset::of([1, 2, 2])
///   assert_eq!(set.count(1), 1)
///   assert_eq!(set.count(2), 2)
/// }
/// ```
pub fn of[T : Compare](arr : FixedArray[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///| Converts an Array to an ImmutableMultiset.
pub fn from_array[T : Compare](arr : Array[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///| Converts an iterator to an ImmutableMultiset.
pub fn from_iter[T : Compare](iter : Iter[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for item in iter {
    set = set.add(item)
  }
  set
}

///| Converts an iterator of (element, count) pairs to an ImmutableMultiset.
pub fn from_iter2[T : Compare](iter : Iter2[T, Int]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for item, times in iter {
    set = set.add(item, times~)
  }
  set
}
