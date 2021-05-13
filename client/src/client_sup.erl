
-module(client_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    {ok, Socket} = tcp:connect(17017),
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [
        #{
        id => server,
        start => {server, start_link, [Socket]},
        restart => permanent,
        shutdown => infinity,
        type => worker,
        modules => [server]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
