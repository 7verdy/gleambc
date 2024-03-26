import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Token {
  Number(value: Int)
  Operator(name: String)
  Parenthesis(open: Bool)
}

pub fn tokenise(input: List(String)) -> #(Token, Int) {
  let first_char = case list.at(input, 0) {
    Ok(c) -> c
    _ -> ""
  }
  case first_char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
      get_number(result.unwrap(list.pop(input, fn(_) { True }), #("", [])).1, [
        result.unwrap(int.parse(first_char), 0),
      ])
    "+" | "-" | "*" | "/" -> get_operator(first_char)
    "(" | ")" -> get_parenthesis(first_char)
    "" -> #(Operator("end"), 0)
    _ -> #(Operator("unknown"), 1)
  }
}

fn get_number(input: List(String), current_number: List(Int)) -> #(Token, Int) {
  let first_digit = case list.at(input, 0) {
    Ok(c) ->
      case int.parse(c) {
        Ok(n) -> n
        _ -> -1
      }
    _ -> -1
  }

  case first_digit {
    0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 -> {
      let pop = case list.pop(input, fn(_) { True }) {
        Ok(rest) -> rest
        _ -> #("", [])
      }
      let new_number = case int.parse(pop.0) {
        Ok(n) -> n
        _ -> -1
      }
      get_number(pop.1, [new_number, ..current_number])
    }
    _ -> #(
      Number(
        current_number
        |> list.reverse
        |> list.fold(0, fn(x, acc) { x + acc }),
      ),
      list.length(current_number),
    )
  }
}

fn get_operator(input: String) -> #(Token, Int) {
  case input {
    "+" -> #(Operator("+"), 1)
    "-" -> #(Operator("-"), 1)
    "*" -> #(Operator("*"), 1)
    "/" -> #(Operator("/"), 1)
    _ -> #(Operator("unknown"), 1)
  }
}

fn get_parenthesis(input: String) -> #(Token, Int) {
  case input {
    "(" -> #(Parenthesis(True), 1)
    ")" -> #(Parenthesis(False), 1)
    _ -> #(Operator("unknown"), 1)
  }
}
