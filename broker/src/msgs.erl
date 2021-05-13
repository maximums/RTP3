-module(msgs).
-include("utils.hrl").

-export([
        serialize/1,
        deserialize/1,
        get_msg_type/1,
        is_persistent/1,
        get_topics/1
    ]).

serialize(Msg) -> mochijson2:encode([Msg#msg.header, Msg#msg.body]).

deserialize(Msg) ->
    Fmsg = mochijson2:decode(Msg),
    #msg{header = get_header(Fmsg), body = get_body(Fmsg)}.

get_header(Msg) -> ej:get({first}, Msg).

get_body(Msg) ->
    case ej:get({last}, Msg) of
        {struct,[]} -> undefined;
        Body -> Body
    end.

get_msg_type(Msg) ->
    [Type | _] = Msg#msg.header,
    list_to_atom(binary_to_list(Type)).

is_persistent(Msg) ->
    [_|Params] = Msg#msg.header,
    [Is_Pers|_] = Params,
    Is_Pers.

get_topics(Msg) ->
    [_|H] = Msg#msg.header,
    [_|Topics] = H,
    [list_to_atom(binary_to_list(X)) || X <- Topics].