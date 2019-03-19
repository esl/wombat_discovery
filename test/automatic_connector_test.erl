-module(automatic_connector_test).
-include_lib("eunit/include/eunit.hrl").

-export([]).

	%?debugFmt("~n ... ~p", []),
%When Connector is started, calls Wombat API to discover node
connector_calls_wombat_api_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, discover_me, fun(Node,Cookie) -> ok end),
	?assertMatch(ok,wombat_api:discover_me(node,cookie)),
	%?debugFmt("~n automatic_connector: ~p", [automatic_connector:do_discover(Nodename,Cookie,Count,Wait)]).
	%?assert(meck:validate(wombat_api)).
	?assertMatch(ok,automatic_connector:do_discover(wombat,wombat,10,1000)),
	meck:unload(wombat_api).

connector_calls_wombat_self_and_tyr_again_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, discover_me, fun(Node,Cookie) -> no_connection end),
	?assertMatch(Ref::reference(),automatic_connector:do_discover(wombat,wombat,10,1000)),
	meck:unload(wombat_api).
	
