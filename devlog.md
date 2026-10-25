Plan/Approach 
Plan: Parse each line of prefix notation left to right with small recursive functions. Each one returns two things, the value it computed and the characters it didn’t use, so the next function can start where the last one stopped.

Steps:

Write a loop that reads lines and stops on quit, with the history as a parameter.
Parse numbers.
Pick what to do from the first character: an operator, $, a digit or an error.
Handle - (one operand) and +, *, / (two operands, with a divide-by-zero check).
Treat leftover text as an error, and print errors without changing the history.
Add each result to the history with cons, and reverse the list before looking up $n.
Print results as floats.
Test each function, then the sample runs.

STAGE ONE:
Added mode detection and loop skelaton

STAGE TWO:
-fail raises an error message as a string and the loop catches it later
-digit? checks for 0 to 9. I used it instead of char-numeric? because that one also accepts non-ASCII digits that string->number cant read
-skip-ws drops leading blanks
-parse-number splits characters at the first non-digit with splitf.at. It returns a list of the number and the characters left over. This pair (value remaining) is the patters every parser follows. 

STAGE THREE:
-negate is just - applied to one value. The spec has no subtraction, so - is only negation
-parse-unary parses one operand with parse-expr and applies the operator to it
-parse-expr is the dispatcher. It skips blanks and looks at the first character Each operator calls a parser for its kind of expression, a digit means a number, and anything else, or no characters at all, is an error. parse-unary and parse-expr call each other, which is why they can handle nesting like --5

STAGE FOUR:
-parse-binary parses the left operand, then parses the right one starting from (second left), which is whatever the left operand didn’t use. That is what makes + 1 2 read left to right. It returns the operator applied to both values, plus whatever the right operand left over
-divide checks for a zero divisor first, since that is an error, and otherwise uses quotient for integer division
-The +, * and / cases in parse-expr are what route to parse-binary

STAGE FIVE:
-evaluate parses a line and then checks that only blanks are left. If other text remains, as in +1 2 2, it raises “Unexpected trailing characters”
-In eval-loop, with-handlers catches any raised string (and any other Racket error) and turns it into either 'ok with a value or 'error with a message. On an error the loop prints Error: ... and recurs with the old history, so a bad line doesn’t disturb anything

STAGE SIX:
-history is threaded through every parser as an extra argument
-parse-history reads the digits after $ and checks that n is between 1 and the length of the history. If so, it returns (list-ref history (- n 1)), and if not it fails
-The history is stored with cons, so the newest result is first. (reverse history) is passed to evaluate, which makes $1 the oldest result, as the spec requires
-On success, (cons value history) becomes the new history, and its length is the id to print
