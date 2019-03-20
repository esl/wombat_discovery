-module(wombat_api).

-export([discover_me/2,call_gen_server/2,set_cookie/2]).
-define(TIMEOUT,15000).

-spec discover_me(NodeName::atom(),Cookie::atom()) -> ok | no_connection | true | term().
discover_me(NodeName,Cookie) ->
	%erlang:set_cookie(NodeName,Cookie),
	wombat_api:set_cookie(NodeName,Cookie),
	TargetCookie = erlang:get_cookie(),
	TargetNode = erlang:node(),
	Target = {wo_discover_dynamic_nodes, NodeName},
	Request = {auto_discover_node, TargetNode, TargetCookie},
	wombat_api:call_gen_server(Target,Request).


call_gen_server(Target,Request) ->
	{_, NodeName} = Target,
	{_, _, TargetCookie} = Request,
	try gen_server:call(Target, Request, ?TIMEOUT) of
		Ans -> Ans
	catch
		exit:{{nodedown, _}, _} -> no_connection;
    	exit:{noproc, _} -> no_connection
	after 
		erlang:set_cookie(NodeName,TargetCookie)
	end.

set_cookie(NodeName,Cookie) ->
	erlang:set_cookie(NodeName,Cookie).