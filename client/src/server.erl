-module(server).
-include("utils.hrl").
-behaviour(gen_server).

%% API
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {user_socket}).

start_link(Socket) -> gen_server:start_link({local, ?MODULE},?MODULE, Socket, []).

init(Socket) ->
    gen_server:cast(self(), connect),
    io:format("____________________________________________INFO_________________________________________________________",[]),
    io:format("msgs:build_msg()  -  return empty msg",[]),
    io:format("msgs:add_header(Message, Header)  -  return msg with Header (is mandatory)",[]),
    io:format("msgs:add_header(Message, Body)  -  return msg with Body",[]),
    io:format("server ! Message - to send msg",[]),
    io:format("_________________________________________________________________________________________________________",[]),
    {ok, #state{user_socket=Socket}}.

handle_cast(connect, State) ->
    io:format("::::::::::::::::::::::~n~p~n",[State#state.user_socket]),
    Client = State#state.user_socket,
    gen_tcp:controlling_process(Client, self()),  
    {noreply, State#state{user_socket = Client}};

handle_cast(_, State) -> {noreply, State}.

handle_info({srv, Msg}, State) ->
    Data = msgs:deserialize(Msg),
    io:format("::::::::::::::::::::::~n~p~n",[Data]),
    {noreply, State};

handle_info(Msg, State) ->
    io:format("::::::::::::::::::::::~n~p~n",[Msg]),
    Data = msgs:serialize(Msg),
    tcp:send(State#state.user_socket, Data),
    {noreply, State}.
           
handle_call(stop, _From, State) -> {stop, normal, stopped, State};
handle_call(_Request, _From, State) -> {reply, ok, State}.
