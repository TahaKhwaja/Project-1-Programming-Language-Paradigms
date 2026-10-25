# Prefix Notation Calculator

Racket calculator, It evaluates prefix-notation expressions and keeps a history of results.

Author: Taha Khwaja
NETID: TOK220002
Date: 10/24/26
Class: CS 4337

## Usage

```
racket calc.rkt         # interactive mode
racket calc.rkt -b      # batch mode (only results and errors)
```

Type `quit` to exit.

## Expressions

- `n` — a number
- `+ a b`, `* a b` — add, multiply
- `/ a b` — integer division (dividing by zero is an error)
- `- a` — negate (there is no subtraction)
- `$n` — the result with history id `n`

Anything left over after a complete expression is an error.

## Example

```
> *+ 1 1 /4 2
1: 4.0
> /5 0
Error: Invalid expression
> +1 2 2
Error: Unexpected trailing characters
```

## Files

- `calc.rkt` — the program
- `devlog.md` — development log
