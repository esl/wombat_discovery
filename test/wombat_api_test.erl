-module(wombat_api_test).
-include_lib("eunit/include/eunit.hrl").

-export([]).

mock_gen_server_test() ->
	meck:new(gen_server, [unstick, passthrough]),
	meck:unload(gen_server).
%	meck:expect(gen_server, call, fun(_Target,_Request,_Timeout) -> its_oke end).
%	?assertMatch(its_oke,wombat_api:discover_me(wombat,wombat)).
%	?assert(meck:validate(gen_server)).