import benchmarks/utils
import gleam/io
import gleamy/bench

import benchmarks/config

import gleam/list
import gleamy/array

pub fn main() {
  bench.run(
    [
      bench.Input("10", utils.build_gleamy_array(10)),
      bench.Input("100", utils.build_gleamy_array(100)),
      bench.Input("1000", utils.build_gleamy_array(1000)),
      bench.Input("10000", utils.build_gleamy_array(10_000)),
      bench.Input("100000", utils.build_gleamy_array(100_000)),
    ],
    [bench.Function("gleamy_array", fn(x) { array.map(x, fn(i) { i + 1 }) })],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()

  bench.run(
    [
      bench.Input("10", utils.build_list(10)),
      bench.Input("100", utils.build_list(100)),
      bench.Input("1000", utils.build_list(1000)),
      bench.Input("10000", utils.build_list(10_000)),
      bench.Input("100000", utils.build_list(100_000)),
    ],
    [bench.Function("list", fn(x) { list.map(x, fn(i) { i + 1 }) })],
    config.bench,
  )
  |> bench.table(config.table)
  |> io.println()
}
