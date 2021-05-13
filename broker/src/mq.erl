-module(mq).
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2
]).

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    {ok, Name} = dets:open_file("durable_queue", []),
    {ok, Name}.

handle_cast({add, Msg}, State) ->
    dets:insert(State, {"Topics: ", msgs:get_topics(Msg), Msg}),
    {noreply, State};
handle_cast({remove, Msg}, State) -> 
    dets:delete(State, {"Topics: ", msgs:get_topics(Msg), Msg}),
    {noreply, State}.

    
handle_call(stop, _From, State) -> {stop, normal, stopped, State};
handle_call(_Request, _From, State) -> {reply, ok, State}.
handle_info(_Info, State) -> {noreply, State}.