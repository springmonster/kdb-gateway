\l mr.q
\d .gw

qry:1!flip`k`c`n`m`r!"g*j**"$\:() / (k)ey, (c)lient call-back, (n)o. of map sub-op outstanding, result of (m)ap sub-op, (r)educe sub-op

sel:{neg[.z.w](`upd;x;@[(0b;)reval@;;{(1b;x)}]@[y;1;{$[`date in cols x:value x;x;([]date:(count x)#.z.d),'x]}])}
del:{.[`.gw.qry;();_;x]}

upd:{[k;x]                                                                              / update (k)ey
  if[k in key qry;                                                                        / no entry, assume an error has been returned already and discard
    if[x 0;qry[k;`c]x;:del k];                                                              / eval call-back, delete entry and return early if error
    .[`.gw.qry;(k;`m);]$[`date in cols x:0!x 1;x,;,[;`date xcols update date:.z.d fr›om x]]; / prepend historical, append real-time
    if[0=qry[k;`n]-:1;qry[k;`c]0b,enlist qry[k;`r]qry[k;`m];del k]];                        / reduce, eval call-back and delete entry if map complete 
  }

ps:{[k;t;c;b;a]                                                                   / partition select
  d:$[not count c 0;0;type c[0;0];0;-11h=type x:c[0;0;1];`date~first` vs x;0];      / is first constraint on date
  v:$[q:0>type b;0;not count b;0;-11h=type v:first value b;`date~first` vs v;0];    / is first grouping on date
  f:$[q;0#`;key b];                                                                 / fields to group on
  g:$[count a;.mr.qa first a;0];                                                    / are there aggregations
  qry[k;`n`r]:$[not d;[r(sel;k;(?;t;c;b;a));1,(::)];                                / no date constraint, send to the rdb 
    not reval @[c[0;0];1;:;.z.d];[h(sel;k;(?;t;c;b;a));1,(::)];                       / date constraint excludes today, send to the hdb
    v or not g;[(h;r)@\:(sel;k;(?;t;c;b;a));2,$[not q;f xkey f xasc;b;distinct;::]];  / first grouping on date or no aggregations, send to both
    [(h;r)@\:(sel;k;(?;t;c;b;first a:.mr.ua a));2,?[;();$[q;0b;f!f];last a]]];        / else map-reduce and send to both
  }

.z.pg:{k:first -1?0Ng;ps . k,1_parse x;qry[k;`c]:{-30!x,y}.z.w;-30!(::)}
.z.ps:{if[x[0]in key .gw;:.gw . x];k:first -1?0Ng;ps . k,1_parse x 1;qry[k;`c]:{neg[x](y;z)}[.z.w;x 0]}

u.x:.z.x,(count .z.x)_(":5011";":5012")
r:neg hopen `$":",u.x 0 / real-time
h:neg hopen `$":",u.x 1 / historical

\
  Usage:

  q gw.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] -p port

  > q gw.q :5011 :5012 -p 5013 &
  > q
  q)h:hopen 5013
  q)h"select spread:ask-bid from t"                                 / real-time
  q)h"select spread:ask-bid from t where date=.z.d-1"               / historical 
  q)h"select spread:ask-bid from t where date>=.z.d-1"              / historical + real-time
  q)h"select spread:ask-bid by date from t where date>=.z.d-1"      / historical + real-time, but no map-reduce
  q)h"select spread:ask-bid from t where date>=.z.d-1"              / historical + real-time, use map-reduce
  q)neg[h](show;"select spread:ask-bid from t where date>=.z.d-1")  / provide a call-back if sending asynchronously
