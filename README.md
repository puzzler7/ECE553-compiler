# ECE553Project

### Team Members
* Bowen Jiang (bj92)
* Andy Zhang (az107)
* Maverick Chung (mc608)

### Links to Compiler Parts
* [Lexer](https://gitlab.oit.duke.edu/bj92/ece553project/-/tree/master/src/lexer)
* 

### Testing Instructions

#### Prerequisites
* [node and npm](https://nodejs.org/)
* [mlton](http://www.mlton.org/)

#### Running tests
* Run `npm install` then `npm test`. 
* The first test should spawn a mlton process to compile the SML into a standalone executable, which is used in the tests that follow.

#### Test details
* In general, snapshots (in `test/*/__snapshots__`) of the executables' output are created to reveal any changes in output between different builds of the code.

##### Lexer
* Tests perform a simple check that the lexer can run on a `.tig` file without crashing (i.e. process does not error and no output to stderr).
* Error messages in stdout are determined by pattern matching `/:[0-9]+\.[0-9]+:/` (which is faulty but good enough for our purposes). positive tests should not have errors, while negative tests should.