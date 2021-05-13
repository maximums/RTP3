-module(mega_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->    
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => 60,
                 period => 3600},

    ChildSpecs = [
        #{
            id => mq,
            start => {mq, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [mq]
        },
    #{
            id => broker_sup,
            start => {broker_sup, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => supervisor,
            modules => [broker_sup]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.


