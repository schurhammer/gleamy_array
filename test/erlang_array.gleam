pub type Array(a)

@external(erlang, "array", "new")
@external(javascript, "./erlang_array.ffi.mjs", "stub")
pub fn new() -> Array(a)

@external(erlang, "array", "set")
@external(javascript, "./erlang_array.ffi.mjs", "stub")
pub fn set(i: Int, val: a, array: Array(a)) -> Array(a)

@external(erlang, "array", "get")
@external(javascript, "./erlang_array.ffi.mjs", "stub")
pub fn get(i: Int, array: Array(a)) -> a

@external(erlang, "array", "size")
@external(javascript, "./erlang_array.ffi.mjs", "stub")
pub fn size(a: Array(a)) -> Int
