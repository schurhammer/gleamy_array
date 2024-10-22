import gleam/int

/// bits per level
const bits = 5

/// 2^bits - 1
const mask = 31

pub opaque type Array(a) {
  Array(size: Int, level: Int, root: Node(a))
}

type Node(a)

@internal
pub fn tuple0() {
  #()
}

@internal
pub fn tuple2(a, b) {
  #(a, b)
}

@external(erlang, "gleamy/array", "tuple0")
fn new_node() -> Node(a)

@external(erlang, "gleamy/array", "tuple2")
fn new_node_2(a: Node(a), b: Node(a)) -> Node(a)

@external(erlang, "erlang", "element")
fn leaf_get_element(index: Int, leaf: Node(a)) -> a

@external(erlang, "erlang", "setelement")
fn leaf_set_element(index: Int, leaf: Node(a), value: a) -> Node(a)

@external(erlang, "erlang", "append_element")
fn leaf_append_element(leaf: Node(a), value: a) -> Node(a)

@external(erlang, "erlang", "element")
fn node_get_element(index: Int, node: Node(a)) -> Node(a)

@external(erlang, "erlang", "setelement")
fn node_set_element(index: Int, node: Node(a), value: Node(a)) -> Node(a)

@external(erlang, "erlang", "append_element")
fn node_append_element(node: Node(a), value: Node(a)) -> Node(a)

@external(erlang, "erlang", "delete_element")
fn delete_element(index: Int, node: Node(a)) -> Node(a)

@external(erlang, "erlang", "tuple_size")
fn node_size(node: Node(a)) -> Int

fn do_push(n: Node(a), i: Int, v: a, level: Int) {
  case level {
    0 -> leaf_append_element(n, v)
    _ -> {
      let key = 1 + int.bitwise_and(int.bitwise_shift_right(i, level), mask)
      case node_size(n) {
        // if key > size we have to create a new internal node
        size if key > size -> {
          let child = new_node()
          let child = do_push(child, i, v, level - bits)
          node_append_element(n, child)
        }
        // otherwise we push inside the existing internal node
        _ -> {
          let child = node_get_element(key, n)
          let child = do_push(child, i, v, level - bits)
          node_set_element(key, n, child)
        }
      }
    }
  }
}

fn do_set(n: Node(a), i: Int, v: a, level: Int) {
  case level {
    0 -> {
      let key = 1 + int.bitwise_and(i, mask)
      leaf_set_element(key, n, v)
    }
    _ -> {
      let key = 1 + int.bitwise_and(int.bitwise_shift_right(i, level), mask)
      let child = node_get_element(key, n)
      let child = do_set(child, i, v, level - bits)
      node_set_element(key, n, child)
    }
  }
}

fn do_pop(n: Node(a), i: Int, level: Int) -> #(Node(a), a) {
  case level {
    0 -> {
      let key = 1 + int.bitwise_and(i, mask)
      let deleted = leaf_get_element(key, n)
      #(delete_element(key, n), deleted)
    }
    _ -> {
      let key = 1 + int.bitwise_and(int.bitwise_shift_right(i, level), mask)
      let child = node_get_element(key, n)
      let #(child, deleted) = do_pop(child, i, level - bits)
      case node_size(child) {
        // if child is empty we shrink the node
        0 -> #(delete_element(key, n), deleted)
        // otherwise we just update it
        _ -> #(node_set_element(key, n, child), deleted)
      }
    }
  }
}

fn do_get(n: Node(a), i: Int, level: Int) -> a {
  case level {
    0 -> {
      let key = 1 + int.bitwise_and(i, mask)
      leaf_get_element(key, n)
    }
    _ -> {
      let key = 1 + int.bitwise_and(int.bitwise_shift_right(i, level), mask)
      let child = node_get_element(key, n)
      do_get(child, i, level - bits)
    }
  }
}

fn do_fold(n: Node(a), f: fn(b, a) -> b, acc: b, l: Int, m: Int, i: Int) -> b {
  case l {
    // leaf that still has more values to fold
    0 if i <= m -> {
      // apply the folding function
      let val = leaf_get_element(i, n)
      let acc = f(acc, val)

      // do the next value
      do_fold(n, f, acc, l, m, i + 1)
    }
    // node that still has more children to fold
    _ if i <= m -> {
      // recurse on the child
      let child = node_get_element(i, n)
      let acc = do_fold(child, f, acc, l - bits, node_size(child), 1)

      // do the next child
      do_fold(n, f, acc, l, m, i + 1)
    }
    // no more elements
    _ -> acc
  }
}

pub fn new() {
  Array(0, 0, new_node())
}

pub fn push(array: Array(a), val: a) -> Array(a) {
  let n = int.bitwise_shift_right(array.size, bits)
  let max = int.bitwise_shift_left(1, array.level)
  case n {
    // grow a new root when necessary
    _ if n >= max -> {
      let child = do_push(new_node(), array.size, val, array.level)
      let root = new_node_2(array.root, child)
      Array(array.size + 1, array.level + bits, root)
    }
    _ -> {
      let root = do_push(array.root, array.size, val, array.level)
      Array(array.size + 1, array.level, root)
    }
  }
}

pub fn pop(array: Array(a)) -> Result(#(Array(a), a), Nil) {
  case array.size {
    0 -> Error(Nil)
    _ -> {
      let #(root, deleted) = do_pop(array.root, array.size - 1, array.level)
      let root_size = node_size(root)

      // shrink the root when necessary
      let array = case root_size {
        1 if array.level > 0 -> {
          let root = node_get_element(1, root)
          Array(array.size - 1, array.level - bits, root)
        }
        _ -> Array(array.size - 1, array.level, root)
      }
      Ok(#(array, deleted))
    }
  }
}

pub fn get(array: Array(a), index: Int) -> Result(a, Nil) {
  case index {
    i if i >= 0 && i < array.size -> Ok(do_get(array.root, index, array.level))
    _ -> Error(Nil)
  }
}

/// This function is slightly faster since it doesn't create a result wrapper.
pub fn unsafe_get(array: Array(a), index: Int) -> a {
  case index {
    i if i >= 0 && i < array.size -> do_get(array.root, index, array.level)
    _ -> panic
  }
}

pub fn set(array: Array(a), index: Int, value: a) -> Result(Array(a), Nil) {
  case index {
    i if i >= 0 && i < array.size -> {
      let root = do_set(array.root, index, value, array.level)
      Ok(Array(array.size, array.level, root))
    }
    _ -> Error(Nil)
  }
}

pub fn fold(array: Array(a), acc: b, fun: fn(b, a) -> b) -> b {
  do_fold(array.root, fun, acc, array.level, node_size(array.root), 1)
}
