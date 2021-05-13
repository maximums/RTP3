-module(forwarder).
-export([send_msg/2]).

send_msg(Msg,Topics) ->
    T = ets:tab2list(topics),
    Users = lists:usort(lists:flatten([proplists:get_all_values(X,T)||X<-Topics])),     % <--- Final Boss
    lists:foreach(fun (N) -> tcp:send(N, msgs:serialize(Msg)) end, Users),
    gen_server:cast(mq, {"Topics: ", msgs:get_topics(Msg), Msg}).