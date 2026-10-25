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

