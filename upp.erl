-module(upp).
-compile(export_all).

% Euler's sieve, filter, seq, is_prime
% tests are in separate module upp_test,
% execute upp_test:run/0 to run all tests


seq(N) ->
    seq([1], N).

seq([H|T], N) when H < N ->
    L = [H+1|[H|T]],
    seq(L, N);

seq([H|T], N) when H == N ->
    lists:reverse([H|T]).


filter(F, L) ->
    R = [X || X <- L, F(X) == true],
    R.

all_primes(N) ->
    %% unfortunately, this is a rather unnecessary
    %% function, considering that is_prime/1
    %% already uses a list of all primes
    %% as part of its trial division
    %% from eulers/1
    List = seq(N),
    Primes = filter(fun is_prime/1, List),
    Primes.

is_prime(N)when N < 2 ->
    false;

is_prime(2) ->
    true;

is_prime(N) when N rem 2 == 0 ->
    false;

is_prime(N) ->
    %% primality test by
    %% trial division
    %% assume N < 10K (Joe).

    %% trial division:
    %% N is prime if not evenly divisible
    %% by P(rime) in sqrt(N) > P  > 2
    
    %% let U be the upper bound
    U = round(math:sqrt(N)),
    Primes = eulers(U),
    [H|T] = Primes,
    Result = N rem H == 0,
    case Result of
	true ->
	    false;
	false ->
	    is_prime(T, N)
    end.

is_prime([], _N) ->
    %% if we've gone through
    %% the whole list of primes
    %% and we have not found a divisor
    %% then N is prime.
    true;

is_prime([H|T], N) -> 
    Result = N rem H == 0,
    case Result of
	true ->
	    false;
	false ->
	    is_prime(T, N)
    end.

eulers(N) -> 
    %% creates a list of primes
    %% in the range 2...N
    %% using Euler's sieve
    
    %% n.b. not super fast
    Range = lists:seq(2, N),
    eulers([], Range).

eulers(X, []) ->
    %% we have exhausted the search range
    %% reverse to get ordered
    lists:reverse(X);

eulers(Found, Range) ->
    %% extract head and tail
    [H|T] = Range,

    %% mark first element as prime
    %% by adding to our list
    Primes = [H|Found],

    %% multiply all elements from original list
    %% with first element
    %% mark for deletion
    NotPrimes = [H*X || X <- Range],

    %% remove from original list sans head
    Searchspace = lists:subtract(T, NotPrimes),

    %% keep searching until we exhaust
    %% the search space
    eulers(Primes, Searchspace).


%% alternatively rotate could be a FIFO queue
%% but that seemed rather slow(???)
deq(Q) ->
    {{_, Item}, Q1} = queue:out(Q),
    {Item, Q1}.

enq(Item, Q) ->
    queue:in(Item, Q).

%% rotates a list  either positive (H->L) or negative (L->H)
%% by shifting Head to Last or the reverse.
%% N is amount of shifts, L is the list.

rotate(N, L) ->
    %% skip unnecessary 
    %% rotations
    Length = length(L),
    R = N rem Length,
    rotate1(R, L).

rotate1(_, []) ->
    [];

rotate1(N, L) when N == 0 ->
    L;

rotate1(N, L) when N > 0 ->   
    %% get head
    [H|T] = L,
    %% reverse tail
    R = lists:reverse(T),
    %% add head 
    I = [H|R],
    %% flip right again
    F = lists:reverse(I),
    rotate(N-1, F);

rotate1(N, L) when N < 0 ->
    %% extract final element
    [H|T] = lists:reverse(L),
    %% put list back in order
    R = lists:reverse(T),
    %% add final as head
    F = [H|R],
    %% keep rotatin'
    rotate(N+1, F).

