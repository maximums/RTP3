-module(broker_server).
-behaviour(gen_server).
-include("utils.hrl").

%% API
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {user_socket}).

start_link(Socket) -> gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    gen_server:cast(self(), accept),
    {ok, #state{user_socket=Socket}}.

handle_cast(accept, State) ->
    io:format("::::::::::::::::::::::~n~p~n",[State#state.user_socket]),
    {ok, Client} = tcp:accept(State#state.user_socket),
    gen_tcp:controlling_process(Client, self()),
    broker_sup:start_socket(),  
    {noreply, State#state{user_socket = Client}};

handle_cast(_, State) -> {noreply, State}.

handle_info({tcp, Socket, <<"quit">>}, State) ->
    io:format("::::::::::::::::::::::FENITO",[]),
    tcp:close(Socket),
    {stop, normal, State};

handle_info({tcp, Socket, Msg}, State) ->
    Data = msgs:deserialize(Msg),
    io:format("::::::::::::::::::::::~n~p~n",[Data]),
    dispatcher:start_dvij({Data, Socket}),
    {noreply, State};
           
handle_info({tcp_closed, _Socket}, State) -> {stop, normal, State};
handle_info({tcp_error, _Socket, _}, State) -> {stop, normal, State};
handle_info(Error, State) -> io:format("Unexpected: ~p~n", [Error]), {noreply, State}.
handle_call(stop, _From, State) -> {stop, normal, stopped, State};
handle_call(_Request, _From, State) -> {reply, ok, State}.
