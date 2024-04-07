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
  |> should.equal(Number(123_456_789, 9))
}

pub fn tokenise_parenthesis_test() {
  tokenise(string.to_graphemes("("))
  |> should.equal(Parenthesis(True))

  tokenise(string.to_graphemes(")"))
  |> should.equal(Parenthesis(False))
}

pub fn tokenise_operator_test() {
  tokenise(string.to_graphemes("+"))
  |> should.equal(Operator("+"))

  tokenise(string.to_graphemes("-"))
  |> should.equal(Operator("-"))

  tokenise(string.to_graphemes("*"))
  |> should.equal(Operator("*"))

  tokenise(string.to_graphemes("/"))
  |> should.equal(Operator("/"))
}

pub fn parser_add_test() {
  parse("1 + 2")
  |> should.equal(3)

  parse("1 + 2 + 3")
  |> should.equal(6)
}

pub fn parser_sub_test() {
  parse("3 - 2")
  |> should.equal(1)

  parse("3 - 2 - 1")
  |> should.equal(0)

  parse("3 - 2 - 2")
  |> should.equal(-1)
}

pub fn parser_mult_test() {
  parse("2 * 3")
  |> should.equal(6)

  parse("2 * 3 * 4")
  |> should.equal(24)
}

pub fn parser_div_test() {
  parse("6 / 3")
  |> should.equal(2)

  parse("6 / 3 / 2")
  |> should.equal(1)
}

pub fn parser_parenthesis_test() {
  parse("(1 + 2) * 2")
  |> should.equal(6)

  parse("(1 + 1) * 2")
  |> should.equal(4)

  parse("2 * (1 + 1)")
  |> should.equal(4)

  parse("2 * (1 + 1) * 2")
  |> should.equal(8)
}

pub fn parse_all_test() {
  parse("5 + 2 * 2 - 6 / 3")
  |> should.equal(7)

  parse("18 / 3 - 2 * 2 + 3")
  |> should.equal(5)

  parse("(5 + 2) * 2 - 6 / 3")
  |> should.equal(12)

  parse("5 + 2 * (6 - 2) / 3")
  |> should.equal(7)
}
