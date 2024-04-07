import gleam/int
import gleam/list
import gleam/result.{unwrap}

pub type Token {
  Number(value: Int, length: Int)
  Operator(name: String)
  Parenthesis(open: Bool)
  Whitespace
}

pub fn tokenise(input: List(String)) -> Token {
  let first_char = case list.at(input, 0) {
    Ok(c) -> c
    _ -> ""
  }

  case first_char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> {
      let rest = list.drop(input, 1)
      get_number(rest, [unwrap(int.parse(first_char), 0)])
    }
    "+" | "-" | "*" | "/" -> get_operator(first_char)
    "(" | ")" -> get_parenthesis(first_char)
    "" -> Operator("end")
    " " | "\t" | "\n" -> Whitespace
    _ -> Operator("unknown")
  }
}

pub fn token_to_string(token: #(Token, Int)) -> String {
  case token {
    #(Number(n, _), len) ->
      "Number(" <> int.to_string(n) <> ") -> " <> int.to_string(len)
    #(Operator(op), _) -> "Operator(" <> op <> ")"
    #(Parenthesis(True), _) -> "Open Parenthesis"
    #(Parenthesis(False), _) -> "Close Parenthesis"
    #(Whitespace, _) -> "Whitespace"
  }
}

fn get_number(input: List(String), current_number: List(Int)) -> Token {
  let first =
    list.at(input, 0)
    |> result.try(int.parse)

  case first {
    Ok(digit) -> {
      let rest = list.drop(input, 1)
      get_number(rest, [digit, ..current_number])
    }
    Error(_) ->
      Number(
        current_number
          |> list.reverse
          |> list.fold(0, fn(x, acc) { x * 10 + acc }),
        list.length(current_number),
      )
  }
}

fn get_operator(input: String) -> Token {
  case input {
    "+" -> Operator("+")
    "-" -> Operator("-")
    "*" -> Operator("*")
    "/" -> Operator("/")
    _ -> Operator("unknown")
  }
}

fn get_parenthesis(input: String) -> Token {
  case input {
    "(" -> Parenthesis(True)
    ")" -> Parenthesis(False)
    _ -> Operator("unknown")
  }
}
