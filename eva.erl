% Billy J.B.
% PARADIS VT17 DSV.
% a simple arithmetic evaluator 
% that receives tuple-shaped parse trees
% and evaluates them.
% eval/1 = unsafe eval
% safe_eval/1 = error-handling eval
% eva/0 = a safe_eval hosting process

% unit tests - execute eva:test/0
% manually run eval proc - execute eva:start/0

-module(eva).
-export([eval/1, safe_eval/1, start/0, test/0, eva/0]).

start() ->
    spawn(?MODULE, eva, []).

eva() ->
    receive
	{Pid, Expression} ->
	    Pid ! {self(), safe_eval(Expression)},
	    eva();
	_Unexpected ->
	    %% ignore and continue
	    eva()
    end.

%% simple
eval({plus, X, Y})->
    eval(X) + eval(Y);
eval({minus, X, Y}) ->
    eval(X) - eval(Y);
eval({times, X, Y}) ->
    eval(X) * eval(Y);
eval({divide, X, Y}) ->
    eval(X) / eval(Y);
eval(X) when is_integer(X) orelse is_float(X) ->
    X.


%% same as above except with
%% handling of eval error
%% (could be pushed down?)

safe_eval({divide, X, Y})  ->
    R1 = safe_eval(X),
    R2 = safe_eval(Y),
    case R1 of
	{error, Msg} ->
	    {error, Msg};
	{_, V1} ->
	    case R2 of
		0 ->
		    {error, divide_by_zero};
		{error, Msg} ->
		    {error, Msg}; %% propagate up
		{_, V2} ->
		   {ok, V1 / V2}
	    end
    end;

safe_eval({times, X, Y}) ->
    R1 = safe_eval(X),
    R2 = safe_eval(Y),
    case R1 of
	{error,Msg} ->
	    {error, Msg};
	{_, V1} ->
	   case R2 of
	       {error, Msg} ->
		   {error, Msg};
	       {_, V2} ->
		   {ok, V1 * V2}
	   end
    end;    

safe_eval({plus, X, Y}) ->
    R1 = safe_eval(X),
    R2 = safe_eval(Y),
    case R1 of
	{error,Msg} ->
	    {error, Msg};
	{_, V1} ->
	   case R2 of
	       {error, Msg} ->
		   {error, Msg};
	      {_, V2} ->
		   {ok, V1 + V2}
	   end
    end;        

safe_eval({minus, X, Y}) ->
    R1 = safe_eval(X),
    R2 = safe_eval(Y),

    case R1 of
	{error,Msg} ->
	    {error, Msg};
	{_,V1} ->
	   case R2 of
	       {error, Msg} ->
		   {error, Msg};
	      {_, V2} ->
		   {ok, V1 - V2}
	   end
    end;    
safe_eval({_, _, _}) ->
    {error, invalid_token};

safe_eval(X) when is_integer(X) orelse is_float(X) ->
    {ok, X};
safe_eval(_X) ->
    {error, invalid_number}.

%% little helper function for PRinting Errors
pre(X) ->
    io:format("Something went dastardly wrong. ~p~n", [X]).

test() ->
    Calculon = eva:start(),
    Mathtest = {plus, 40, {times, 3, {minus, 110, 10}}},
    Calculon ! {self(), Mathtest},
    receive
	{_, {ok,340}} ->
	    ok;
	X ->
	    pre(X),
	    throw(eval_math_broken)
    end,
    Invalid = {plus, swoob, 50},
    Calculon ! {self(), Invalid},
    receive
	{_, {error, invalid_number}} ->
	    ok;
	Y ->
	    pre(Y),
	    throw(eval_error_handling_broken)
    end,
    Malformed = "invalid_message",
    Calculon ! Malformed,
    %% the server does not respond to broken requests
    %% but should not crash
    Q = {divide, 340, Mathtest},
    %% also division fun!
    Calculon ! {self(), Q},
    receive
	{_, {ok, 1.0}} ->
	    ok;
	{_, {ok, _Z}} ->
	    throw(eval_math_broken)
		
    after 3000 ->
	    throw(eval_process_died)
    end,
    hooray.
	    
	
