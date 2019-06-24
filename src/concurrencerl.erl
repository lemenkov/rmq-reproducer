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

generate_node_names() ->
	[ list_to_atom(io_lib:format("test~b@localhost.localdomain", [X])) || X <- lists:seq(0,9) ].

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
	%error_logger:error_msg("A: ~p~n", [N]),
	timer:sleep(100),
	add(Nodes, [N|Processed]).

remove([], Nodes) ->
	timer:sleep(100),
	add(Nodes, []);
remove([N|Nodes], Processed) ->
	[Node] = (catch ets:take(sys_dist, N#connection.node)),
	%error_logger:error_msg("R: ~p (~p)~n", [Node, N]),
	timer:sleep(100),
	remove(Nodes, [Node|Processed]).

get_infos() ->
	case catch net_kernel:nodes_info() of
		{ok, _} -> ok;
		Any -> error_logger:error_msg("T: ~w~n", [Any])
	end,
	timer:sleep(10),
	get_infos().

substitution_test() ->
	meck:new(net_kernel, [unstick, passthrough]),
	meck:expect(net_kernel, init, fun meck_net_kernel:init/1),

	net_kernel:start(['foobar@localhost.localdomain', longnames]),

	NodeNames = concurrencerl:generate_node_names(),
	[ net_adm:ping(N) || N <- NodeNames ],

	spawn(fun() -> remove(ets:tab2list(sys_dist), []) end),
	get_infos(),

	ok.
