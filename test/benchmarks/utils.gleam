import erlang_array
import gleam/dict
import gleam/list
import gleamy/array
import glearray

fn do_strict_range(start: Int, stop: Int, acc) {
  case start > stop {
    True -> acc
    False -> do_strict_range(start, stop - 1, [stop, ..acc])
  }
}

/// Create a list of integers such that `from <= n < to` in ascending order.
pub fn strict_range(from start: Int, to stop: Int) {
  do_strict_range(start, stop - 1, [])
}

pub fn build_erlang_array(n) {
  strict_range(0, n)
  |> list.fold(erlang_array.new(), fn(a, i) { erlang_array.set(i, i, a) })
}

pub fn build_glearray(n) {
  strict_range(0, n)
  |> list.fold(glearray.new(), fn(a, i) { glearray.copy_push(a, i) })
}

pub fn build_gleamy_array(n) {
  strict_range(0, n)
  |> list.fold(array.new(), fn(a, i) { array.push(a, i) })
}

pub fn build_gleam_dict(n) {
  strict_range(0, n)
  |> list.fold(dict.new(), fn(a, i) { dict.insert(a, i, i) })
}

pub fn build_list(n) {
  strict_range(0, n)
}

pub fn random_numbers(n) {
  let sample_size = 10_000
  strict_range(0, n)
  |> list.repeat(1 + sample_size / n)
  |> list.flatten()
  |> list.shuffle()
  |> list.take(sample_size)
}
