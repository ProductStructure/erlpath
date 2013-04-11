-module(erlpath).

-include_lib("kernel/include/file.hrl").
-behavior(e2_task).
-include_lib("eunit/include/eunit.hrl").
-export([start_link/0, handle_task/1, attemp_reload/1, get_search_dirs/0, add_dirs/1]).
-record(state, {last,  search_dirs}).

get_search_dirs() ->
    {ok, SearchDirs }	= application:get_env(erlpath, 'search_dirs'),
    SearchDirs.

start_link() ->
    SearchDirs          = ?MODULE:get_search_dirs(),
    {ok,PWD}		= file:get_cwd(),      
    State		=  #state{
      last = stamp(),
      search_dirs = [filename:join([PWD, Dir, "*/ebin"])|| Dir <- SearchDirs]
     },
    e2_task:start_link(?MODULE, State, [{repeat, 1000 }]).
 
handle_task(State) ->
    ok = ?MODULE:attemp_reload(State),
    {repeat, State}.


add_dirs([]) ->
    ok;
add_dirs(NewDirs) ->
    io:format("~s:~p (~p) Adding paths ~p~n", [?FILE, ?LINE, self(), NewDirs]),
    code:add_pathsz(NewDirs),
    ok.


attemp_reload(State) ->
    Path	= code:get_path(),
    SearchDirs	= string:join(State#state.search_dirs, " "),
    Dirs	= string:tokens(os:cmd("ls -1d "++ SearchDirs),"\n"),
    NewDirs	= Dirs -- Path,
    ?MODULE:add_dirs(NewDirs).
    
    
    

stamp() ->
    erlang:localtime().


