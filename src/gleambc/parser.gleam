import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleambc/lexer.{Number, Operator, Parenthesis, Whitespace, tokenise}

pub fn parse(input: String) -> Int {
  let string_list = string.to_graphemes(input)
  let #(values, operators) = get_stacks(string_list, [], [])

  let #(values, operators) = reduce_mult_div(values, operators, [], 0)

  compute(values, operators)
}

fn reduce_mult_div(
  values: List(Int),
  operators: List(lexer.Token),
  new_ops: List(lexer.Token),
  index: Int,
) -> #(List(Int), List(lexer.Token)) {
  case operators {
    [] -> #(values, new_ops)
    [Operator("*"), ..rest] -> {
      let right: Int = case list.at(values, index + 1) {
        Ok(x) -> x
        Error(_) -> 0
      }
      let left: Int = case list.at(values, index) {
        Ok(x) -> x
        Error(_) -> 0
      }

      let before_values = list.split(values, index).0
      let after_values = list.drop(values, index + 2)

      let product = left * right

      let new_values = list.concat([before_values, [product], after_values])
      let reset = list.concat([new_ops, rest])

      reduce_mult_div(new_values, reset, [], 0)
    }
    [Operator("/"), ..rest] -> {
      let right: Int = case list.at(values, index + 1) {
        Ok(x) -> x
        Error(_) -> 0
      }
      let left: Int = case list.at(values, index) {
        Ok(x) -> x
        Error(_) -> 0
      }

      let before_values = list.split(values, index).0
      let after_values = list.drop(values, index + 2)

      let difference = left / right

      let new_values = list.concat([before_values, [difference], after_values])
      let reset = list.concat([new_ops, rest])

      reduce_mult_div(new_values, reset, [], 0)
    }
    [current, ..rest] -> {
      reduce_mult_div(values, rest, [current, ..new_ops], index + 1)
    }
  }
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
