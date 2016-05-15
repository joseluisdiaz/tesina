-module(fact).
-export([factorial_rec/0, rec_customer/2, get/0]).

rec_customer(N, Customer) ->
    receive
        {K} -> Customer ! {(N * K)}
    end.

factorial_rec() ->
    receive
        {N, Customer} when N == 0 ->
            Customer ! {1};
        {N, Customer} when N >= 1 ->
            C = spawn(fact, rec_customer, [N, Customer] ),
            self() ! { N - 1, C }
    end,
    factorial_rec().

get() -> receive T -> T after 1000 -> true end.


