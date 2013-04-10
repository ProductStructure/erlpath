-module(erlpath).

-include_lib("kernel/include/file.hrl").
-behavior(e2_task).

-export([start_link/0, handle_task/1, attemp_reload/1]).
-record(state, {last, path, search_dirs}).

start_link() ->
    {ok, SearchDirs } = application:get_env('search_dirs'),
    {ok,PWD} = file:get_cwd(),      
    State    =  #state{
      last = stamp(),
     % path = code:get_path(),
      search_dirs = [filename:join([PWD, Dir, "*/ebin"])|| Dir <- SearchDirs]
     },
    e2_task:start_link(?MODULE, State, [{repeat, 1000 }]).
 
handle_task(State) ->
    ok = attemp_reload(State),
    {repeat, State}.


attemp_reload(State) ->
    Path	= code:get_path(),
    SearchDirs	= string:join(State#state.search_dirs, " "),
    Dirs	= string:tokens(os:cmd("ls -1d "++ SearchDirs),"\n"),
    NewDirs	= Dirs -- Path,
    case NewDirs of 
	[] ->
	    ok;
	_ ->
	    io:format("~s:~p (~p) Adding paths ~p~n", [?FILE, ?LINE, self(), NewDirs]),
	    ok =  code:add_pathsz(NewDirs),
	    ok
    end.
    
    
    

stamp() ->
    erlang:localtime().


