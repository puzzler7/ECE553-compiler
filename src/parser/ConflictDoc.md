Justification of Shift/Reduce Conflicts

We have 12 exps that start with exp, namely PLUS, MINUS, TIMES, DIVIDE, LT, NEQ, LE, GT, GE, EQ, AND, OR. We give these
precedence, so there are no shift/reduce conflicts between these 12 actions. However, with IF/THEN(/ELSE), WHILE/DO, FOR,
and hackybrackthing. The reason that we want to shift is to capture everything in the later expression before reducing.

State 51 refers to hackybrackthing, which refers to initializing an array with a value. Here, we want to capture everything
in the initial expression before reducing. 

State 93 refers to the epxression after DO in a WHILE loop. For the expression in the loop, we want to shift as to not leave 
anything hanging, similar to state 51.

State 94 has 13 conflicts - 12 of which are the usual conflicts, for the same reasons as above. The extra one comes from parsing a THEN.
If we have an ELSE, the language specifically wants to shift to the ELSE and expression before reducing.

State 118 refers to the expression after an ELSE, which follows the same logic as 51 and 93.

State 130 refers to the expression after DO in a FOR loop. The logic is identical to the WHILE loop.

Hence we have 61 shift/reduce conflicts, which are all accounted for.
------------------------------------------------------------------------------

To illustrate the example between the 12 exprs, consider something of the form:

WHILE/FOR ... DO 5 + 5;

or

arr[10] of 5 + 5;

or

IF ... THEN 5 + 5;

or 

IF ... THEN ... ELSE 5 + 5;


If we reduce in any of these cases before shifting, we get


(WHILE/FOR ... DO 5) + 5;

or

(arr[10] of 5) + 5;

or

(IF ... THEN 5) + 5;

or 

(IF ... THEN ... ELSE 5) + 5;

where we leave + 5 hanging. Hence, we want to shift to get the expr 5 + 5 before reducing.


