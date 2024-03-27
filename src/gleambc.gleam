import gleam/int
import gleam/io
import gleam/string
import gleambc/parser.{parse}

pub fn main() {
  let input = "11 + 22 - 3"
  let result = parse(input)
  io.println(
    string.concat(["Input: '", input, "' | Result: ", int.to_string(result)]),
  )
}
