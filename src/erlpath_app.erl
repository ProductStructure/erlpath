-module(erlpath_app).

-behavior(e2_application).

-export([init/1, init/0, start/0]).

start() ->
    e2_application:start_with_dependencies(erlpath_app).

init([]) ->
    io:format("~p:~p (~p) init([]) ~n", [?MODULE, ?LINE, self()]),
    {ok, [erlpath, {erlpath}]}.

init() ->
    io:format("~p:~p (~p) init() ~n", [?MODULE, ?LINE, self()]),
    {ok, [erlpath]}.
