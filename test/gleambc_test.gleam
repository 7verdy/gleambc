import gleam/string
import gleeunit
import gleeunit/should
import gleambc/lexer.{Number, Operator, Parenthesis, tokenise}

pub fn main() {
  gleeunit.main()
}

pub fn tokenise_number_test() {
  tokenise(string.to_graphemes("123456789"))
  |> should.equal(#(Number(123_456_789), 9))
}

pub fn tokenise_parenthesis_test() {
  tokenise(string.to_graphemes("("))
  |> should.equal(#(Parenthesis(True), 1))

  tokenise(string.to_graphemes(")"))
  |> should.equal(#(Parenthesis(False), 1))
}

pub fn tokenise_operator_test() {
  tokenise(string.to_graphemes("+"))
  |> should.equal(#(Operator("+"), 1))

  tokenise(string.to_graphemes("-"))
  |> should.equal(#(Operator("-"), 1))

  tokenise(string.to_graphemes("*"))
  |> should.equal(#(Operator("*"), 1))

  tokenise(string.to_graphemes("/"))
  |> should.equal(#(Operator("/"), 1))
}
