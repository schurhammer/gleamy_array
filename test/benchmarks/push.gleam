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
  bench.run(
    [
      bench.Input("10", utils.strict_range(0, 10)),
      bench.Input("100", utils.strict_range(0, 100)),
      bench.Input("1000", utils.strict_range(0, 1000)),
      bench.Input("10000", utils.strict_range(0, 10_000)),
      bench.Input("100000", utils.strict_range(0, 100_000)),
    ],
    [
      bench.Function("gleamy_array", fn(x) {
        list.fold(x, array.new(), fn(a, i) { array.push(a, i) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", utils.strict_range(0, 10)),
      bench.Input("100", utils.strict_range(0, 100)),
      bench.Input("1000", utils.strict_range(0, 1000)),
      bench.Input("10000", utils.strict_range(0, 10_000)),
      bench.Input("100000", utils.strict_range(0, 100_000)),
    ],
    [
      bench.Function("erlang_array", fn(x) {
        list.fold(x, erlang_array.new(), fn(a, i) { erlang_array.set(i, i, a) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", utils.strict_range(0, 10)),
      bench.Input("100", utils.strict_range(0, 100)),
      bench.Input("1000", utils.strict_range(0, 1000)),
      bench.Input("10000", utils.strict_range(0, 10_000)),
    ],
    [
      bench.Function("glearray", fn(x) {
        list.fold(x, glearray.new(), fn(a, i) { glearray.copy_push(a, i) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", utils.strict_range(0, 10)),
      bench.Input("100", utils.strict_range(0, 100)),
      bench.Input("1000", utils.strict_range(0, 1000)),
      bench.Input("10000", utils.strict_range(0, 10_000)),
      bench.Input("100000", utils.strict_range(0, 100_000)),
    ],
    [
      bench.Function("dict", fn(x) {
        list.fold(x, dict.new(), fn(a, i) { dict.insert(a, i, i) })
      }),
    ],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()
}
