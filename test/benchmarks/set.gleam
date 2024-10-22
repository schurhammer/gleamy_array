import benchmarks/utils
import gleam/dict
import gleam/io
import gleam/list
import gleamy/bench
import glearray

import benchmarks/config

import erlang_array
import gleamy/array

pub fn main() {
  let r10 = utils.random_numbers(10)
  let r100 = utils.random_numbers(100)
  let r1000 = utils.random_numbers(1000)
  let r10000 = utils.random_numbers(10_000)
  let r100000 = utils.random_numbers(100_000)

  bench.run(
    [
      bench.Input("10", #(utils.build_gleamy_array(10), r10)),
      bench.Input("100", #(utils.build_gleamy_array(100), r100)),
      bench.Input("1000", #(utils.build_gleamy_array(1000), r1000)),
      bench.Input("10000", #(utils.build_gleamy_array(10_000), r10000)),
      bench.Input("100000", #(utils.build_gleamy_array(100_000), r100000)),
    ],
    [
      bench.Function("gleamy_array", fn(x) {
        let #(a, x) = x
        list.each(x, fn(i) { array.set(a, i, 0) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", #(utils.build_gleamy_array(10), r10)),
      bench.Input("100", #(utils.build_gleamy_array(100), r100)),
      bench.Input("1000", #(utils.build_gleamy_array(1000), r1000)),
      bench.Input("10000", #(utils.build_gleamy_array(10_000), r10000)),
      bench.Input("100000", #(utils.build_gleamy_array(100_000), r100000)),
    ],
    [
      bench.Function("gleamy_array (unwrapped)", fn(x) {
        let #(a, x) = x
        list.each(x, fn(i) { array.unsafe_set(a, i, 0) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", #(utils.build_erlang_array(10), r10)),
      bench.Input("100", #(utils.build_erlang_array(100), r100)),
      bench.Input("1000", #(utils.build_erlang_array(1000), r1000)),
      bench.Input("10000", #(utils.build_erlang_array(10_000), r10000)),
      bench.Input("100000", #(utils.build_erlang_array(100_000), r100000)),
    ],
    [
      bench.Function("erlang_array", fn(x) {
        let #(a, x) = x
        list.each(x, fn(i) { erlang_array.set(i, 0, a) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", #(utils.build_glearray(10), r10)),
      bench.Input("100", #(utils.build_glearray(100), r100)),
      bench.Input("1000", #(utils.build_glearray(1000), r1000)),
      bench.Input("10000", #(utils.build_glearray(10_000), r10000)),
      bench.Input("100000", #(utils.build_glearray(100_000), r100000)),
    ],
    [
      bench.Function("glearray", fn(x) {
        let #(a, x) = x
        list.each(x, fn(i) { glearray.copy_set(a, i, 0) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", #(utils.build_gleam_dict(10), r10)),
      bench.Input("100", #(utils.build_gleam_dict(100), r100)),
      bench.Input("1000", #(utils.build_gleam_dict(1000), r1000)),
      bench.Input("10000", #(utils.build_gleam_dict(10_000), r10000)),
      bench.Input("100000", #(utils.build_gleam_dict(100_000), r100000)),
    ],
    [
      bench.Function("dict", fn(x) {
        let #(a, x) = x
        list.each(x, fn(i) { dict.insert(a, i, 0) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()
}
