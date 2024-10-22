pub type Array(a)

@external(erlang, "array", "new")
pub fn new() -> Array(a)

@external(erlang, "array", "set")
pub fn set(i: Int, val: a, array: Array(a)) -> Array(a)

@external(erlang, "array", "get")
pub fn get(i: Int, array: Array(a)) -> a

@external(erlang, "array", "size")
pub fn size(a: Array(a)) -> Int
