-module(w).
-export([exists/3, worker/3, master_wait/2, test_1/0, test_2/0]).

worker(Element, Fun, Master) ->
    Master ! {Fun(Element)}.

master_wait(0, Master) ->
    Master ! {false};
master_wait(N, Master) ->
    receive
        {true} ->
           Master ! {true};
        {false} ->
           master_wait(N - 1, Master)
    end.

exists(Array, Fun, Client) ->
    %% crea a master_wait, quien coordina e implementa la lógica de
    %% espero true o length(Array) false
    Waiter = spawn(?MODULE, master_wait, [length(Array), Client]),

     %% crea un conjunto de "trabajadores"
    [spawn(?MODULE, worker, [X, Fun, Waiter]) || X <- Array ].

% --- Test ---
is_two(2) -> true;
is_two(_) -> false.

test_1() ->
    L = [1,3,4,5,6],
    spawn(?MODULE, exists, [L, fun is_two/1, self()]),
    receive X -> {ok, X} after 10000 -> {err} end.

test_2() ->
    L = [1,2,3,4,5,6],
    spawn(?MODULE, exists, [L, fun is_two/1, self()]),
    receive X -> {ok, X} after 10000 -> {err} end.
