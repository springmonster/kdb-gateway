\d .mr

a0:(count;first;last;sum;prd;min;max;all;any;distinct),a1:(avg;wsum;wavg;var;dev;cov;cor;svar;sdev;scov;med)
a2:(
  {(%;(sum;("f"$;x));(sum;(not null ::;x)))};
  {(sum;(*;("f"$;x);y))};
  {(%;(wsum;x;y);(sum;(*;x;(not null ::;y))))};
  {(cov;x;x)};
  {(sqrt;(var;x))};
  {(-;(avg;(*;("f"$;x);y));(*;(avg;x);(avg;y)))};
  {(%;(cov;x;y);(*;(dev;x);(dev;y)))};
  {(scov;x;x)};
  {(sqrt;(svar;x))};
  {(*;(%;(count;`i);(+;-1;(count;`i)));(cov;x;y))};
  {'`part})

IN:{$[99h<type x;x in y;0]}                       / if x is a function, is it in the list of aggregate functions
qa:{$[qb x;0;IN[first x;a0];1;max qa each 1_x]}   / recurse into parse tree looking for aggregate functions
qb:{(2>count x)or(type x)and not 11=type x}       / check if atom, singleton or non-general, non-symbol list
qd:{$[(count)~first x;(distinct)~first x 1;0]}    / check if (count;(distinct;`sym)) i.e. 'count distinct sym'

ua:{((`$string til count u)!u;                    / map sub-operations
  x2[;u:distinct raze x1 each x]each x:x0 each x)}  / decompose complex aggregations, complete mapping by accounting for 'count distinct', then reduce
x0:{$[qb x;x;                                     / if there's no aggregation, return x
  IN[first x;a1];x0 a2[a1?first x]. 1_x;            / else-if complex aggregation, lookup decomposition
  x0 each x]}                                       / else, recurse into parse tree
x1:{$[qb x;();                                    / if there's no aggregation, return an empty list
  IN[first x;a0];$[qd x;1_x;enlist x];              / else-if simple or complex aggregation, check for (count;(distinct;`sym)) and map by dropping count
  raze x1 each 1_x]}                                / else, recurse into parse tree
x2:{$[qb x;x;                                     / if there's no aggregation, return x
  IN[first x;a0];                                   / else-if simple or complex aggregation
    $[qd x;(count;(distinct;(raze;xy[x 1]y)));        / if (count;(distinct;`sym)), reduce with (count;(distinct;(raze;x))) where x is the result of map
      [y:xy[x]y;                                        / else find the position of the result of map
        $[(distinct)~first x;(distinct;(raze;y));         / then, if aggregation is a 'distinct', reduce with (distinct;raze(x)) where x is the result of map
          (count)~first x;(sum;y);                          / else-if aggregation is a 'count', reduce by summing individual counts
          (first x;y)]]];                                   / else, aggregation is consistent across map-reduce e.g. sum
  x2[;y]each x]}                                    / else, recurse into parse tree
xy:{`$string first where x~/:y}                   / find the position of the given map function in the list of map functions

\
Usage:

  This library is an adaptation of the partition select functionality
  provided by Kx in q.k

  Its purpose is to generalise the map-reduce implementation therein.

  There are two functions of interest:

    1. Given a parse tree, use .mr.qa to detect an aggregation in the
       query

    2. Decompose the aggregate argument to a functional select query
       into map and reduce sub-operations using .mr.ua

    e.g. 

       q)o:([]sym:`a`b`c;bid:4 1 4;ask:5 2 8)             / partition one
       q)p:([]sym:`a`b`c;bid:2 1 5;ask:5 2 7)             / partition two
       q)q:parse"select spread:avg ask-bid by sym from t" / query across partitions
       q).mr.qa first value last q                        / check for aggreagte functions
       1
       q)mr:.mr.ua last q                                 / decompose into map and reduce sub-operations
       q)m:@[q;4;:;first mr]                              / substitute map operation
       q)r:@[q;4;:;last mr]                               / substitute reduce operation
       q)eval@[r;1;:;]raze 0!/:eval each@[m;1;:;]each`o`p / map query to partitions, reduce
       sym| spread
       ---| ------
       a  | 2     
       b  | 1     
       c  | 3     
