-module(automatic_connector_test).
-include_lib("eunit/include/eunit.hrl").

-export([]).

connector_calls_wombat_api_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, discover_me, fun(_Node,_Cookie) -> ok end),
	?assertMatch(ok,wombat_api:discover_me(node,cookie)),
	?assertMatch(ok,automatic_connector:do_discover(wombat,wombat,10,1000)),
	meck:unload(wombat_api).

connector_calls_self_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, discover_me,['_','_'], no_connection),
	?assert(is_reference(automatic_connector:do_discover(wombat,wombat,10,1000))),
	meck:unload(wombat_api).

connector_calls_self_and_tyr_again_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:new(automatic_connector, [passthrough]),
	meck:new(wombat_discovery_app, [passthrough]),
	meck:expect(wombat_discovery_app,load_config, [], {a,b,10,0}),
	meck:expect(wombat_api, discover_me, ['_','_'], no_connection),
	automatic_connector:start_link(),
	timer:sleep(500),
	?assertMatch(11, meck:num_calls(automatic_connector,handle_info, [{try_again, '_'}, '_'])),
	meck:unload(wombat_api),
	meck:unload(automatic_connector),
	meck:unload(wombat_discovery_app).