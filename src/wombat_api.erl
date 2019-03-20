-module(wombat_api).

-export([discover_me/2]).
-define(TIMEOUT,15000).

-spec discover_me(NodeName::atom(),Cookie::atom()) -> ok | no_connection | true | term().
discover_me(NodeName,Cookie) ->
	erlang:set_cookie(NodeName,Cookie),
	TargetCookie = erlang:get_cookie(),
	TargetNode = erlang:node(),
	Target = {wo_discover_dynamic_nodes, NodeName},
	Request = {auto_discover_node, TargetNode, TargetCookie},

	try gen_server:call(Target, Request, ?TIMEOUT) of
		Ans -> Ans
	catch
		exit:{{nodedown, _}, _} -> no_connection;
    	exit:{noproc, _} -> no_connection
	after 
		erlang:set_cookie(NodeName,TargetCookie)
	end.