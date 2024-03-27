import gleam/string
import gleeunit
import gleeunit/should
import gleambc/lexer.{Number, tokenise}

pub fn main() {
  gleeunit.main()
}

pub fn tokenise_test() {
  tokenise(string.to_graphemes("123456789"))
  |> should.equal(#(Number(123_456_789), 9))
}
