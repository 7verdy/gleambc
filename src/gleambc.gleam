import gleam/erlang
import gleam/int
import gleam/io
import gleam/string
import gleambc/parser.{parse}

pub fn main() {
  let stdin = erlang.get_line("Enter an expression to evaluate: ")

  let expression = case stdin {
    Ok(value) -> string.trim(value)
    Error(_) -> ""
  }
  let result = parse(expression)

  io.println(
    "Input: '" <> expression <> "' | Result: " <> int.to_string(result),
  )
}
