import gleam/io
import gleam/list
import gleeunit

import gleamy/array

pub fn main() {
  gleeunit.main()
}

fn do_strict_range(start: Int, stop: Int, acc) {
  case start > stop {
    True -> acc
    False -> do_strict_range(start, stop - 1, [stop, ..acc])
  }
}

fn strict_range(from start: Int, to stop: Int) {
  do_strict_range(start, stop - 1, [])
}

pub fn from_list_test() {
  let n = 1000

  strict_range(0, n)
  |> list.each(fn(i) {
    let l = strict_range(0, i)
    let a = list.fold(l, array.new(), fn(a, i) { array.push(a, i) })
    let b = array.from_list(l)
    case a == b {
      True -> Nil
      False -> {
        io.debug(a)
        io.debug(b)
        panic
      }
    }
  })
}

pub fn push_pop_are_inverse_test() {
  let n = 1000

  strict_range(0, n)
  |> list.each(fn(i) {
    let a =
      strict_range(0, i)
      |> list.fold(array.new(), fn(array, i) { array.push(array, i) })

    strict_range(0, i)
    |> list.each(fn(i) {
      // test getter
      let assert Ok(x) = array.get(a, i)
      case x == i {
        True -> Nil
        False -> {
          io.debug(#("wrong number", x, "expected", i))
          panic
        }
      }
      // test setter
      let assert Ok(a) = array.set(a, i, 0)
      let assert Ok(x) = array.get(a, i)
      case x == 0 {
        True -> Nil
        False -> {
          io.debug(#("wrong number", x, "expected", i))
          panic
        }
      }
    })

    let assert Ok(#(b, popped)) =
      a
      |> array.push(i + 1)
      |> array.pop()
    let assert True = popped == i + 1

    strict_range(0, i)
    |> list.each(fn(i) {
      let assert Ok(x) = array.get(b, i)
      case x == i {
        True -> Nil
        False -> {
          io.debug(#("wrong number", x, "expected", i))
          panic
        }
      }
    })
    case a == b {
      True -> Nil
      False -> {
        io.debug("not equal")
        io.debug(a)
        io.debug(b)
        panic as "not equal"
      }
    }
  })
}
