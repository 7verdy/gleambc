import gleam/string
import gleeunit
import gleeunit/should
import gleambc/lexer.{Number, Operator, Parenthesis, tokenise}
import gleambc/parser.{parse}

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

pub fn parser_precedence_test() {
  parse("1 + 2")
  |> should.equal(3)

  parse("2 * 3")
  |> should.equal(6)

  parse("1 + 2 * 3")
  |> should.equal(7)

  parse("3 * 5 + 2 * 5")
  |> should.equal(25)

  parse("5 + 2 * 2 - 6 / 3")
  |> should.equal(7)

  parse("18 / 3 - 2 * 2 + 3")
  |> should.equal(5)
}
