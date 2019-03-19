%%%-------------------------------------------------------------------
%% @doc examples public API
%% @end
%%%-------------------------------------------------------------------

-module(examples_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	io:format("Examples application starting... ~n"),
    examples_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
	io:format("Examples application stopping... ~n"),
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
