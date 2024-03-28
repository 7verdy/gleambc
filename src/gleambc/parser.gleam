import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleambc/lexer.{Number, Operator, Parenthesis, Whitespace, tokenise}

pub fn parse(input: String) -> Int {
  let string_list = string.to_graphemes(input)
  let #(values, operators) = get_stacks(string_list, [], [])

  let #(values, operators) = reduce_parenthesis(values, operators)

  let #(values, operators) = reduce_mult_div(values, operators, [], 0)

  compute(values, operators)
}

fn reduce_parenthesis(values: List(Int), operators: List(lexer.Token)) {
  // ) -> #(List(Int), List(lexer.Token)) {
  let open_par = case list.find(operators, fn(op) { op == Operator("(") }) {
    Ok(op) -> op
    Error(_) -> Operator("end")
  }
  case open_par {
    Operator("end") -> #(values, operators)
    _ -> {
      let close_par = case
        list.find(operators, fn(op) { op == Operator(")") })
      {
        Ok(op) -> op
        Error(_) -> Operator("end")
      }
      case close_par {
        Operator("end") -> #(values, operators)
        _ -> {
          let open_index = get_index(operators, open_par)
          let close_index = get_index(operators, close_par)

          let before_values = list.split(values, open_index).0
          let after_values = list.drop(values, close_index)

          let between_values =
            list.take(list.drop(values, open_index), close_index - open_index)

          let between_operators =
            list.take(
              list.drop(operators, open_index + 1),
              close_index - open_index - 1,
            )

          let before_operators = list.split(operators, open_index).0
          let after_operators = list.drop(operators, close_index + 1)

          let #(par_values, par_operators) =
            reduce_mult_div(between_values, between_operators, [], 0)

          let value_in_par = compute(par_values, par_operators)

          let new_values =
            list.concat([before_values, [value_in_par], after_values])

          reduce_parenthesis(
            new_values,
            list.concat([before_operators, after_operators]),
          )
        }
      }
    }
  }
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
      let new_ops = list.concat([new_ops, [current]])
      reduce_mult_div(values, rest, new_ops, index + 1)
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
    #(Parenthesis(True), _) -> {
      get_stacks(list.drop(input, 1), values, [Operator("("), ..operators])
    }
    #(Parenthesis(False), _) -> {
      get_stacks(list.drop(input, 1), values, [Operator(")"), ..operators])
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

fn get_index(list: List(_), item: _) -> Int {
  case list {
    [] -> -1
    [x, ..xs] -> {
      case x == item {
        True -> 0
        False -> {
          let index = get_index(xs, item)
          case index {
            -1 -> -1
            _ -> index + 1
          }
        }
      }
    }
  }
}
