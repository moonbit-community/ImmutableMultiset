///|
pub enum ImmutableMultiset[T] {
  Empty
  Bucket(Bucket[T])
  Singleton(T, Int)
}

///|
struct Bucket[T] {
  map : @immut/hashmap.T[T, Int]
  size : Int
}

///|
fn Bucket::new[T]() -> Bucket[T] {
  { map: @immut/hashmap.new(), size: 0 }
}

///|
fn Bucket::contains[T : Eq + Hash](bucket : Bucket[T], item : T) -> Bool {
  bucket.map.contains(item)
}

///|
fn Bucket::add[T : Eq + Hash](bucket : Bucket[T], item : T) -> Bucket[T] {
  let cnt = bucket.map.get(item).or_else(fn() { 0 })
  let new_map = bucket.map.add(item, cnt + 1)
  { map: new_map, size: bucket.size + 1 }
}

///|
fn Bucket::insert[T : Eq + Hash](
  bucket : Bucket[T],
  item : T,
  count : Int
) -> Bucket[T] {
  let cnt = bucket.map.get(item).or_else(fn() { 0 })
  let new_map = bucket.map.add(item, cnt + count)
  { map: new_map, size: bucket.size + count }
}

///|
fn Bucket::size[T](bucket : Bucket[T]) -> Int {
  bucket.size
}

///|
fn Bucket::get[T : Eq + Hash](bucket : Bucket[T], item : T) -> Int {
  bucket.map.get(item).or_else(fn() { 0 })
}

///|
fn Bucket::remove[T : Eq + Hash](bucket : Bucket[T], item : T, count~: Int = 1) -> Bucket[T] {
  let cnt = bucket.map.get(item).or_else(fn() { 0 })
  let new_map = if count == -1 {
    bucket.map.remove(item)
  } else {
    if cnt - count <= 0 {
      bucket.map.remove(item)
    } else {
      bucket.map.add(item, cnt - count)
    }
  }
  { map: new_map, size: bucket.size - cnt }
}

///|
fn Bucket::iter[T : Eq + Hash](bucket : Bucket[T]) -> Iter[(T, Int)] {
  bucket.map.iter()
}

///|
fn Bucket::iter2[T : Eq + Hash](bucket : Bucket[T]) -> Iter2[T, Int] {
  bucket.map.iter2()
}

///|
pub fn contains[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Bool {
  match self {
    Empty => false
    Bucket(bucket) => bucket.contains(item)
    Singleton(v, _) => v == item
  }
}

///|
pub fn ImmutableMultiset::new[T]() -> ImmutableMultiset[T] {
  Empty
}

///|
pub fn ImmutableMultiset::singleton[T](item : T) -> ImmutableMultiset[T] {
  Singleton(item, 1)
}

///|
/// Count the number of occurrences of an item in the multiset
/// 
pub fn count[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Int {
  match self {
    Empty => 0
    Bucket(bucket) => bucket.get(item)
    Singleton(v, cnt) => if v == item { cnt } else { 0 }
  }
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
  count~ : Int = 1
) -> ImmutableMultiset[T] {
  match self {
    Empty => Singleton(item, 1)
    Bucket(bucket) => Bucket(bucket.insert(item, count))
    Singleton(v, cnt) =>
      if v == item {
        Singleton(v, cnt + 1)
      } else {
        Bucket(Bucket::new().insert(v, cnt).insert(item, count))
      }
  }
}

///|
/// Remove an item from the multiset, if it exists, decrement the count
/// If argument count is -1, remove all occurrences
pub fn remove[T : Eq + Hash](
  self : ImmutableMultiset[T],
  item : T,
  count~ : Int = 1
) -> ImmutableMultiset[T] {
  match self {
    Empty => Empty
    Bucket(bucket) => {
      let bucket = bucket.remove(item, count=count)
      if bucket.size() == 0 {
        Empty
      } else {
        Bucket(bucket)
      }
    }
    Singleton(v, _) => if v == item { Empty } else { self }
  }
}

///|
pub fn size[T](self : ImmutableMultiset[T]) -> Int {
  match self {
    Empty => 0
    Bucket(bucket) => bucket.size()
    Singleton(_, _) => 1
  }
}

///|
pub fn is_empty[T](self : ImmutableMultiset[T]) -> Bool {
  match self {
    Empty => true
    Bucket(bucket) => bucket.size() == 0
    Singleton(_, _) => false
  }
}

///|
pub fn op_get[T : Eq + Hash](self : ImmutableMultiset[T], item : T) -> Int {
  self.count(item)
}

// Two multisets operations

///| 
/// Two multisets intersection operation
/// If same item exists in both multisets, the minimum of counts is taken
pub fn intersection[T : Eq + Hash](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
  match self {
    Empty => Empty
    Bucket(bucket) =>
      match other {
        Empty => self
        Bucket(other_bucket) => {
          let mut new_bucket = Bucket::new()
          if bucket.size() > other_bucket.size() {
            for item, count in other_bucket.iter2() {
              let bucket_cnt = bucket.get(item)
              new_bucket = new_bucket.insert(
                item,
                @math.minimum(bucket_cnt, count),
              )
            }
          } else {
            for item, count in bucket.iter2() {
              let bucket_cnt = bucket.get(item)
              new_bucket = new_bucket.insert(
                item,
                @math.minimum(bucket_cnt, count),
              )
            }
          }
          Bucket(new_bucket)
        }
        Singleton(value, cnt) =>
          if bucket.contains(value) {
            Singleton(value, @math.minimum(bucket.get(value), cnt))
          } else {
            Empty
          }
      }
    Singleton(value, count) =>
      match other {
        Empty => Empty
        Singleton(other_value, other_count) =>
          if value == other_value {
            Singleton(value, @math.minimum(count, other_count))
          } else {
            Empty
          }
        Bucket(other_bucket) =>
          if other_bucket.contains(value) {
            Singleton(value, @math.minimum(count, other_bucket.get(value)))
          } else {
            Empty
          }
      }
  }
}

///|
/// Two multisets difference operation
/// If same item exists in both multisets, the difference of counts is taken
/// If the count of an item in the first multiset is less than the second, it is removed
fn difference[T : Eq + Hash](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
  match self {
    Empty => Empty
    Bucket(bucket) =>
      match other {
        Empty => self
        Bucket(other_bucket) => {
          let mut new_bucket = Bucket::new()
          for item, count in bucket.iter2() {
            let other_count = other_bucket.get(item)
            if count > other_count {
              new_bucket = new_bucket.insert(item, count - other_count)
            }
          }
          Bucket(new_bucket)
        }
        Singleton(value, cnt) =>
          if bucket.contains(value) {
            Singleton(value, @math.maximum(cnt - other.count(value), 0))
          } else {
            self
          }
      }
    Singleton(value, count) =>
      match other {
        Empty => self
        Singleton(other_value, other_count) =>
          if value == other_value {
            if count > other_count {
              Singleton(value, count - other_count)
            } else {
              Empty
            }
          } else {
            self
          }
        Bucket(other_bucket) =>
          if other_bucket.contains(value) {
            Singleton(value, @math.maximum(count - other_bucket.get(value), 0))
          } else {
            self
          }
      }
  }
}

///|
/// Two multisets union operation
/// If same item exists in both multisets, the sum of counts is taken
pub fn union[T : Eq + Hash](
  self : ImmutableMultiset[T],
  other : ImmutableMultiset[T]
) -> ImmutableMultiset[T] {
  match self {
    Empty => other
    Bucket(bucket) =>
      match other {
        Empty => self
        Bucket(other_bucket) => {
          let mut new_bucket = Bucket::new()
          for item, count in bucket.iter2() {
            let other_count = other_bucket.get(item)
            new_bucket = new_bucket.insert(item, count + other_count)
          }
          Bucket(new_bucket)
        }
        Singleton(value, cnt) => Bucket(bucket.insert(value, cnt))
      }
    Singleton(value, count) =>
      match other {
        Empty => self
        Bucket(other_bucket) => Bucket(other_bucket.insert(value, count))
        Singleton(other_value, other_count) =>
          if value == other_value {
            Singleton(value, other_count + count)
          } else {
            let new_bucket = Bucket::new()
              .insert(value, count)
              .insert(other_value, other_count)
            Bucket(new_bucket)
          }
      }
  }
}


// overload operators




// other types for conversion
///|
pub fn of[T : Eq + Hash](arr : FixedArray[T]) -> ImmutableMultiset[T] {
  let mut set = ImmutableMultiset::new()
  for _, item in arr {
    set = set.add(item)
  }
  set
}
