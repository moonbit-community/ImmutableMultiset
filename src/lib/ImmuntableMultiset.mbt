///|
pub struct ImmutableMultiset[T] {
  mut map : @immut/hashmap.T[T, Int]
  size : Int
}

///|
pub fn contains[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Bool {
  self.map.contains(item)
}

///|
pub fn ImmutableMultiset::new[T]() -> ImmutableMultiset[T] {
  { map: @immut/hashmap.new(), size: 0 }
}

///|
/// Count the number of occurrences of an item in the multiset
/// 
pub fn count[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Int {
  self.map.get(item).or_else(fn() { 0 })
}

///| 
/// Add an item to the multiset, if it already exists, increment the count
/// 
/// test "multiset::add" {
///   let mut set = ImmutableMultiset::new()
///   set = set.add(1)
///   set = set.add(2)
///   assert_eq!(set.size(), 2)
/// }
pub fn add[T : Eq + Hash](
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

///|
/// Insert an item to the multiset, if it already exists, replace the count
pub fn insert[T : Eq + Hash](
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
  self.map = self.map.add(item, times)
  { map: self.map.add(item, times), size: new_size }
}

///|
/// Remove an item from the multiset, if it exists, decrement the count
/// If argument count is -1, remove all occurrences
pub fn remove[T : Eq + Hash](
  self : ImmutableMultiset[T],
  item : T,
  times~ : Int = 1
) -> ImmutableMultiset[T] {
  if times < -1 {
    abort("times must be -1 or greater")
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

///|
pub fn size[T](self : ImmutableMultiset[T]) -> Int {
  self.size
}

///|
pub fn is_empty[T](self : ImmutableMultiset[T]) -> Bool {
  self.size == 0
}

// Two multisets operations

///| 
/// Two multisets intersection operation
/// If same item exists in both multisets, the minimum of counts is taken
pub fn intersection[T : Eq + Hash](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
  let new_set = if self.size() > other.size() {
    let mut new_set = other
    for item, count in other.iter2() {
      let self_count = self.count(item)
      if self_count > 0 {
        let min_count = @math.minimum(count, self_count)
        new_set = new_set.insert(item, times=min_count)
      }
    }
    new_set
  } else {
    let mut new_set = self
    for item, count in self.iter2() {
      let other_count = other.count(item)
      if other_count > 0 {
        let min_count = @math.minimum(count, other_count)
        new_set = new_set.insert(item, times=min_count)
      }
    }
    new_set
  }
  new_set
}

///|
/// Two multisets difference operation
/// If same item exists in both multisets, the difference of counts is taken
/// If the count of an item in the first multiset is less than the second, it is removed
pub fn difference[T : Eq + Hash](
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
        new_set = new_set.remove(item, times=-1)
      }
    }
  }
  new_set
}

///|
/// Two multisets union operation
/// If same item exists in both multisets, the sum of counts is taken
pub fn union[T : Eq + Hash](
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

///|
pub fn elems[T : Eq + Hash](self : ImmutableMultiset[T]) -> Iter[T] {
  self.map.keys()
}

///|
pub fn iter[T : Eq + Hash](self : ImmutableMultiset[T]) -> Iter[(T, Int)] {
  self.map.iter()
}

///|
pub fn iter2[T : Eq + Hash](self : ImmutableMultiset[T]) -> Iter2[T, Int] {
  self.map.iter2()
}

///|
pub fn op_get[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Int {
  self.count(item)
}

///|
pub impl[T : Eq + Hash] BitOr for ImmutableMultiset[T] with lor(
  self,
  other : ImmutableMultiset[T]
) {
  self.union(other)
}

///|
pub impl[T : Eq + Hash] BitAnd for ImmutableMultiset[T] with land(
  self,
  other : ImmutableMultiset[T]
) {
  self.intersection(other)
}

///|
pub impl[T : Eq + Hash] Sub for ImmutableMultiset[T] with op_sub(
  self,
  other : ImmutableMultiset[T]
) {
  self.difference(other)
}

///|
pub impl[T : Eq + Hash] Eq for ImmutableMultiset[T] with op_equal(
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
pub fn of[T : Eq + Hash](arr : FixedArray[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///|
pub fn from_array[T : Eq + Hash](arr : Array[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}

///|
pub fn from_iter[T : Eq + Hash](iter : Iter[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for item in iter {
    set = set.add(item)
  }
  set
}

///|
pub fn from_iter2[T : Eq + Hash](iter : Iter2[T, Int]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for item, times in iter {
    set = set.add(item, times~)
  }
  set
}

///|
pub fn from_set[T : Eq + Hash](set : Set[T]) -> ImmutableMultiset[T] {
  let mut multiset = ImmutableMultiset::new()
  for item in set {
    multiset = multiset.add(item)
  }
  multiset
}
