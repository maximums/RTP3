-module(topics).
-include("utils.hrl").
-export([
    subscribe_to/2,
    unsubscribe_from/2,
    get_ava_topics/0,
    req_new_topic/1
]).

subscribe_to(Topics, Client)->
    TT = add(Topics,Client,ets:tab2list(topics),[]),
    ets:delete_all_objects(topics),
    ets:insert(topics, TT).

add([H|Ts], Client, Q, Acc) ->
    T=[{H, [Client|proplists:get_value(H,Q)]}|Acc],
    add(Ts,Client,Q,T);

add([],_,_,Acc) -> Acc.

unsubscribe_from(Topics, Client) -> 
    TT = remove(Topics,Client,ets:tab2list(topics),[]),
    ets:delete_all_objects(topics),
    ets:insert(topics, TT).

remove([H|Ts], Client, Q, Acc) ->
    T=[{H, lists:delete(Client,proplists:get_value(H,Q))} | Acc],
    remove(Ts,Client,Q,T);

remove([],_,_,Acc) -> Acc.


get_ava_topics() -> proplists:get_keys(ets:tab2list(topics)).
req_new_topic([H|Ts]) -> 
    req_topic(H),
    req_new_topic(Ts);
req_new_topic([]) -> ok.
req_topic(Topic) -> ets:insert(topics, {Topic, []}).