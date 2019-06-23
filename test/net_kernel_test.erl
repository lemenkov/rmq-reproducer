-module(net_kernel_test).
-compile([export_all, nowarn_export_all]).

-include_lib("eunit/include/eunit.hrl").

add([], Nodes) ->
	timer:sleep(100),
	remove(Nodes, []);
add([N|Nodes], Processed) ->
	ets:insert(sys_dist, N),
	timer:sleep(100),
	add(Nodes, [N|Processed]).

remove([], Nodes) ->
	timer:sleep(100),
	add(Nodes, []);
remove([N|Nodes], Processed) ->
	ets:insert(sys_dist, N),
	timer:sleep(100),
	remove(Nodes, [N|Processed]).
	
substitution_test() ->
	meck:new(net_kernel, [unstick, passthrough]),
	meck:expect(net_kernel, init, fun meck_net_kernel:init/1),

	net_kernel:start(['foobar@localhost.localdomain', longnames]),
	Nodes = concurrencerl:generate_connections(),

	spawn(

	error_logger:tty(true),
	error_logger:error_msg("T: ~w~n", [ets:tab2list(sys_dist)]),
	timer:sleep(1000),
        ?assertEqual(ok1, io:format("test")).
