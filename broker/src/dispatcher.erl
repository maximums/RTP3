-module(dispatcher).
-export([start_dvij/1]).

start_dvij({Msg, Client}) -> action(msgs:get_msg_type(Msg),{Msg, Client}).

action(subscribe, {Msg, Client}) -> topics:subscribe_to(msgs:get_topics(Msg), Client);
action(unsubscribe, {Msg, Client}) -> topics:unsubscribe_from(msgs:get_topics(Msg),Client);
action(data, {Msg, _Client}) -> send(msgs:is_persistent(Msg), Msg);
action(command, {_Msg,Client}) -> tcp:send(Client, msgs:serialize(topics:get_ava_topics()));
action(conn_publi, {Msg,_Client}) -> topics:req_new_topic(msgs:get_topics(Msg)). 

send(true, Msg) -> 
    gen_server:cast(mq, {add, {srv, Msg}}),                                                % save msg first
    forwarder:send_msg({srv, Msg}, msgs:get_topics(Msg));
send(false, Msg) -> forwarder:send_msg({srv, Msg}, msgs:get_topics(Msg)).


    