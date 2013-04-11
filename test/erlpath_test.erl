-module(erlpath_test).

-include_lib("eunit/include/eunit.hrl").
-record(state, {last,  search_dirs}).

start_link_test_() ->
    {
      setup,
      fun () -> 
	       meck:new(e2_task),
	       meck:new(erlpath, [passthrough])
      end,
      fun (_) -> meck:unload([e2_task, erlpath])
      end,
      ?_test(
	 begin
	     meck:expect(erlpath,
			 get_search_dirs,
			 fun() ->
				 ["deps"]
			 end),

	     meck:expect(e2_task,
			 start_link,
			 fun(erlpath, State, [{repeat, 1000}]) ->
				 [_Dir] = State#state.search_dirs,
				 ?debugVal("fix this")
			 end),
	     erlpath:start_link(),
	     ?assert(meck:called(e2_task,start_link, '_'))
	 end)}.



handle_task_test_() ->
    {
      setup,
      fun () -> meck:new(erlpath, [passthrough]) end,
      fun (_) -> meck:unload([ erlpath])         end,
      ?_test(
	 begin
	     State = make_ref(),
	     meck:expect(erlpath,
			 attemp_reload,
			 fun(EState) ->
				 ?assertEqual(State, EState)
			 end),

	     {repeat, State} = erlpath:handle_task(State),
	     ?assert(meck:called(erlpath,attemp_reload, '_'))
	 end)}.




add_dirs_test_() ->
    {
      setup,
      fun ()  -> 
	      meck:new(code, [unstick,passthrough])
      end,
      fun (_) ->
	      ok
      end,
      ?_test(
	 begin
	     Dirs = ["/home/erlang/test/dir/ebin"],
	     meck:expect(code,
			 add_pathsz,
			 fun(EDirs) ->
				 ?assertEqual(Dirs, EDirs)
			 end),
	     ?assertEqual(ok,erlpath:add_dirs([])),
	     ?assertNot(meck:called(code,add_pathsz, '_')),
	     ?assertEqual(ok,erlpath:add_dirs(Dirs)),
	     ?assert(meck:called(code,add_pathsz, '_'))
	 end)}.


%% attempt_reload_test_() ->
%%     {
%%       setup,
%%       fun () -> 
%% 	      meck:new(string, [unstick]),
%% 	      meck:new(erlpath, [passthrough])
%%       end,
%%       fun (_) -> meck:unload([ erlpath, string])         end,
%%       ?_test(
%% 	 begin
%% 	     State = #state{search_dirs = ["test", "test2"]},
%% 	     RetVal = make_ref(),
%% 	     meck:expect(string, tokens, fun(In) ->					  
%% 					  ["/test/dir/ebin","/test/dir2/ebin"]
%% 				  end),
%% 	     meck:expect(erlpath,
%% 			 add_dirs,
%% 			 fun(Dirs) ->
%% 				 ?assertEqual(["/test/dir/ebin", "/test/dir2/ebin"], Dirs),
%% 				 {test,RetVal }
%% 			 end),

%% 	     {test, RetVal} = erlpath:attemp_reload(State),
%% 	     ?assert(meck:called(erlpath,add_dirs, '_'))
%% 	 end)}.

