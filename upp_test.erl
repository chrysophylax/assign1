-module(upp_test).
-compile(export_all).
-import(upp, [seq/1, filter/2, rotate/2, is_prime/1, eulers/1]).
 
run() ->
    ok = seq_test(),
    ok = filter_test(),
    ok = rotate_test(),
    ok = is_prime_test(),
    ok = eulers_test(),
    hooray.

rotate_test() ->
    List = [a,b,c,d,e,f],
    List = rotate(round(math:pow(1666,30)), List),
    [a,b,c,d,e,f] = rotate(-666666666666666, List),
    [b,c,d,e,f,a] = rotate(1, List),
    [f,a,b,c,d,e] = rotate(-1, List),
    ok.

seq_test() ->
    S = lists:seq(1,5),
    S = seq(5),
    ok.

filter_test() ->
    Even = fun(X) ->
		   Even = X rem 2 == 0,
		   case Even of
		       true ->
			   true;
		       false ->
			   false
		   end
	   end,
    List = [1,2,3,4,5],
    [2,4] = filter(Even, List),
    ok.

eulers_test() ->
    %% test Euler's sieve
    %% the 1000th prime is 7919
    [H|_] = lists:reverse(eulers(7920)),
    7919 = H,
    ok.

is_prime_test() ->
    false = is_prime(-155324543),
    false = is_prime(1),
    true = is_prime(2),
    false = is_prime(46),
    true = is_prime(7),
    %% random primes from The Prime Pages
    %% by Prof. Chris Caldwell
    %% primes.utm.edu
    true = is_prime(2399),
    true = is_prime(9817),
    true = is_prime(103573),
    true = is_prime(104119),
    false = is_prime(104235),
    false = is_prime(104679),
    true = is_prime(15485863),
  % true = is_prime(1043955301), <- slow
    ok.
