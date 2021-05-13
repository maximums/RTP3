-module(broker_sup).

-behaviour(supervisor).

-export([start_link/0, start_socket/0]).
-export([init/1]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    {ok, Port} = application:get_env(port),
    {ok, LSocket} = tcp:listen(Port),
    io:format("Listening on port:~w~n",[Port]),
    spawn_link(fun empty_listeners/0),
    
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => 60,
                 period => 3600},

    ChildSpecs = [
        #{
            id => broker,
            start => {broker_server, start_link, [LSocket]},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [broker_server]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

start_socket() -> supervisor:start_child(?MODULE, []).
empty_listeners() -> [start_socket() || _ <- lists:seq(1,2)], ok.

