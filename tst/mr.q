time:10:00:00.000+til 5
sym:`AAPL`TSLA`AAPL`GOOG`MSFT
nyse:([]time;sym;bid:139.96 678.89 139.98 2574.38 277.66;ask:139.99 678.92 140.01 2574.43 277.69;bsize:100 400 200 300 300 100;asize:200 100 100 300 400)
nsdq:([]time;sym;bid:139.97 678.90 139.99 2574.35 277.65;ask:139.99 678.91 140.00 2574.39 277.67;bsize:50 150 75 50 200;asize:25 115 35 70 120)

select n:count i by sym from t
select open:first bid by sym from t
select high:max bid by sym from t
select low:min bid by sym from t
select close:last bid by sym from t
select bsum:sum bsize by sym from t
select aprd:prd asize by sym from t
select clean:all bid<ask by sym from t
select crossed:any bid>ask by sym from t
select bdist:distinct bid, adist:distinct ask by sym from t
select bndist:count distinct bid, andist:count distinct ask by sym from t
select spread:avg ask-bid by sym from t
select vwsp:bsize wsum bid by sym from t
select vwap:bsize wavg bid by sym from t
select bvar:var bid by sym from t
select bdev:dev bid by sym from t
select bacov:bid cov ask by sym from t
select bacor:bid cor ask by sym from t
select bsvar:svar bid by sym from t
select bsdev:sdev bid by sym from t
select bascov:bid scov ask by sym from t

/ select with 1b by-clause
/ select with 0b by-clause
/ select with constraint e.g. sym in `AAPL`GOOG
