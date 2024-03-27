import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleambc/lexer.{Number, Operator, Parenthesis, Whitespace, tokenise}

pub fn parse(input: String) -> Int {
  let string_list = string.to_graphemes(input)
  let #(values, operators) = get_stacks(string_list, [], [])

  compute(values, operators)
}

fn get_stacks(
  input: List(String),
  values: List(Int),
  operators: List(lexer.Token),
) -> #(List(Int), List(lexer.Token)) {
  let token = tokenise(input)
  case token {
    #(Operator("end"), _) -> #(
      values
        |> list.reverse,
      operators
        |> list.reverse,
    )
    #(Whitespace, _) -> get_stacks(list.drop(input, 1), values, operators)
    #(Operator(op), _) -> {
      get_stacks(list.drop(input, 1), values, [Operator(op), ..operators])
    }
    #(Number(n), len) -> {
      get_stacks(list.drop(input, len), [n, ..values], operators)
    }
    // Ignore for now
    #(Parenthesis(_), _) -> {
      get_stacks(list.drop(input, 1), values, operators)
    }
  }
}

fn compute(values: List(Int), operators: List(lexer.Token)) -> Int {
  case operators {
    [] -> {
      result.unwrap(list.at(values, 0), 0)
    }
    [Operator(op), ..rest] -> {
      let right_left = list.take(values, 2)
      case op {
        "+" -> {
          let sum =
            result.unwrap(list.at(right_left, 0), 0)
            + result.unwrap(list.at(right_left, 1), 0)
          compute([sum, ..list.drop(values, 2)], rest)
        }
        "-" -> {
          let difference =
            result.unwrap(list.at(right_left, 0), 0)
            - result.unwrap(list.at(right_left, 1), 0)
          compute([difference, ..list.drop(values, 2)], rest)
        }
        "*" -> {
          let product =
            result.unwrap(list.at(right_left, 0), 0)
            * result.unwrap(list.at(right_left, 1), 0)
          compute([product, ..list.drop(values, 2)], rest)
        }
        "/" -> {
          let division =
            result.unwrap(list.at(right_left, 0), 0)
            / result.unwrap(list.at(right_left, 1), 0)
          compute([division, ..list.drop(values, 2)], rest)
        }
        _ -> {
          io.println("Unknown operator")
          0
        }
      }
    }
    _ -> {
      io.println("Unknown operator")
      0
    }
  }
}
