# Lexer

This part of the compiler takes an input program and lexes it into tokens for the parser to analyze.

### Running
In the SML command line, run `CM.make "sources.cm";` then `Parse.parse "filename.tig";` to compile the lexer and print its output to stdout.

### Handling Strings
We handle strings in a separate state, triggered by an open quote. We maintain a string ref of the string parsed so far, which we add to each step. We parse escape characters appropriately, throw an error on illegal characters (e.g. unescaped newlines and illegal escape characters), and add all other characters to the string ref. When a close quote is detected, we return a token containing the string ref.

NOTE: We do not account for the escape character `\^c`, as it was clarified on [Piazza](https://piazza.com/class/kk4ixtvzfsa3kf?cid=34) that we did not have to.

### Handling Comments
We handle comments much in the same way as strings – when we see a `/*`, we move to a comment state and increment the comment counter. We ignore all input except `/*` and `*/`, incrementing and decrementing the counter appropriately. When the counter reaches zero, we return to normal code lexing.

### Handling Errors
When we detect an error, we print an error message to stdout and continue lexing. We are considering changing error prints to stderr in the future, for ease of our test suite and potentially for parsing.

### Handling EOF
To parse EOF, we first check if we are currently parsing a string or comment. If we are, we throw an appropriate error. We then return an EOF token.

### Other Interesting Bits
We built a testing framework in NodeJS. Details for running it are in the main README. These tests test against all of the provided testfiles, as well as some custom testfiles which stress test our comment and string parsing.

Additionally, our parser has support for both Unix and Windows style newlines (LF vs CRLF).


