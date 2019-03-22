-module(wombat_api_test).
-include_lib("eunit/include/eunit.hrl").

-export([]).

mock_gen_server_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, set_cookie, ['_', '_'], true),
	meck:expect(wombat_api, call_gen_server, ['_','_'], ok),
	?assertMatch(ok, wombat_api:discover_me(wombat,wombat)),
	meck:unload(wombat_api).

discover_me_right_return_values_test() ->
	meck:new(wombat_api, [passthrough]),
	meck:expect(wombat_api, set_cookie, ['_', '_'], true),
	meck:expect(wombat_api, call_gen_server, [{wo_discover_dynamic_nodes, wombat},{auto_discover_node, '_', '_'}], ok),
	?assertMatch(ok, wombat_api:discover_me(wombat,wombat)),
	meck:unload(wombat_api).