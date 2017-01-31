# endoscope
Toolkit for analysis of endofunctions on small sets

Input some function ::  a -> a -> a.

*First result, [Optimal brute force automorpihism checking] (https://oeis.org/A186202)


* Examples include Zn under addition, Zn under multiplication, boolean matrix multiplication, Conway's game of life on a toroidal grid, ...

Input a generator [a].

Outputs:

* Graph of the endofunction under iteration

* Index, period, idempotent, cycleEntry of each element.

* Idempotent functions

* Reluctant functions

* Connected components

* Min dominating set of the detection graph.  For two functions f and g; g detects f if f^i == g for some number of iterations i.

