import gleam/io
import gleam/string
import gleambc/lexer.{token_to_string, tokenise}

pub fn main() {
  let input = string.to_graphemes("123456789")
  io.print(token_to_string(tokenise(input)))
}
