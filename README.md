# gleambc

GleamBC is an attempt at making a calculator in Gleam.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

```sh
# Provide expression on stdin
$ echo -e '15 * 7 - 6 * 6' | gleam run
    Compiled in 0.01s
     Running gleambc.main
Enter an expression to evaluate: Input: '15 * 7 - 6 * 6' | Result: '69'
```
