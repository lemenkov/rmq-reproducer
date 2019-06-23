-module(concurrencerl).
-compile([export_all, nowarn_export_all]).

-include_lib("kernel/include/net_address.hrl").

-record(connection, {
                     node,          %% remote node name
                     conn_id,       %% Connection identity since Erlang 21 (f89fb92384280e2939414287a2ecb8f86a199318)
                     state,         %% pending | up | up_pending
                     owner,         %% owner pid
                     pending_owner, %% possible new owner
                     address,       %% #net_address
                     waiting = [],  %% queued processes
                     type           %% normal | hidden
                    }).

% [{connection,'test1@localhost.localdomain', {1,#Ref<0.887588218.3454402561.231403>}, up,<0.89.0>,undefined, {net_address,{{127,0,0,1},33371}, "localhost.localdomain",tcp,inet}, [],normal}]

generate_connections() ->
	[	#connection{
			node = list_to_atom(io_lib:format("test~b@localhost.localdomain", [X])),
			conn_id = {1, make_ref()},
			state = up,
			owner = self(),
			address = #net_address{address = {{127,0,0,1}, 33333 + X}, host = "localhost.localdomain", protocol = tcp, family = inet},
			waiting = [],
			type = hidden
		} || X <- lists:seq(1,50)].

get_nodes(Which) ->
    get_nodes(ets:first(sys_dist), Which).

get_nodes('$end_of_table', _) ->
    [];
get_nodes(Key, Which) ->
    case ets:lookup(sys_dist, Key) of
        [Conn = #connection{state = up}] ->
            [Conn#connection.node | get_nodes(ets:next(sys_dist, Key),
                                              Which)];
        [Conn = #connection{}] when Which =:= all ->
            [Conn#connection.node | get_nodes(ets:next(sys_dist, Key),
                                              Which)];
        _ ->
            get_nodes(ets:next(sys_dist, Key), Which)
    end.

add([], Nodes) ->
	timer:sleep(100),
	remove(Nodes, []);
add([N|Nodes], Processed) ->
	ets:insert(sys_dist, N),
	%error_logger:error_msg("A: ~w~n", [N]),
	timer:sleep(500),
	add(Nodes, [N|Processed]).

remove([], Nodes) ->
	timer:sleep(100),
	add(Nodes, []);
remove([N|Nodes], Processed) ->
	ets:insert(sys_dist, N),
	%error_logger:error_msg("R: ~w~n", [N]),
	timer:sleep(500),
	remove(Nodes, [N|Processed]).

get_infos() ->
	error_logger:error_msg("T: ~w~n", [catch net_kernel:nodes_info()]),
	%error_logger:error_msg("T: ~w~n", [ets:select(sys_dist, [{#connection{node = '$1', _ = '_'}, [], ['$1']}])]),
	timer:sleep(500),
	get_infos().

substitution_test() ->
	meck:new(net_kernel, [unstick, passthrough]),
	meck:expect(net_kernel, init, fun meck_net_kernel:init/1),

	net_kernel:start(['foobar@localhost.localdomain', longnames]),
	Nodes = concurrencerl:generate_connections(),

	spawn(fun() -> add(Nodes, []) end),
	get_infos(),

    ok.

%% End of Module.
