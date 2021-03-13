# Typechecker

### Running
In the SML command line, run 

```
CM.make "sources.cm";
Main.main "filename.tig";
```

This will compile the parser and typechecker, parse the input file into an AST, print the AST to stdout, and then finally print any type errors. For typechecker output only, run `Main.typecheckOnly "filename.tig";` instead.

### Misc. Info

Because we do not implement a `BOTTOM` type, if any type error is detected, many additional, possibly unrelated errors will follow. This is a feature.

Cycle detection uniquely throws a `CycleInTypeDec` exception instead of calling `ErrorMsg.error`. This is to terminate execution of the typechecker and prevent infinite loops due to the cycle.


### Jest testing
With node installed, run
```
npm install
npm test -- typechecker -u 
```
to run typechecker tests and update relevant snapshots.

These tests simply test the stdout on a regex to match `ErrorMsg.error`, expecting no matches in positive tests and at least one match in negative tests. Whether the error messages are the correct error is not checked.

Note test16.tig will say it fails because it involves cycle detection, and our tests do not recognize the `CycleInTypeDec` exception to be an error message.