-module(broker_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ets:new(topics,[set, public, {write_concurrency, true}, {read_concurrency, true}, named_table]),
    meaga_sup:start_link().

stop(_State) -> ok.

